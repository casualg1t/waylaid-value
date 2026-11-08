const assert=require('node:assert/strict'),fs=require('node:fs');
const M=require('../tools/rewards-model.js'),data=JSON.parse(fs.readFileSync('fixtures/rewards-market-data.json'));
const base={level:20,held:0,learned:false,sort:'net'},rows=M.build(data,base);
assert.equal(rows.length,321);
for(const r of rows){
 if(r.total!=null){assert.equal(r.total,r.route.net+r.materials);assert.equal(r.upfront,r.route.gross+r.materials);assert(r.route.favor>=r.needed);}
 if(r.missing>0||r.craftDataMissing||r.extraGoldUnknown)assert.equal(r.total,null);
}
for(const className of ['Hunter','Priest','Warrior','Paladin','Shaman','Rogue','Druid','Mage','Warlock']){
 for(const level of [20,39,40,60]){
  const visible=M.filter(rows,{...base,className,level});
  for(const r of visible){assert(M.armorFor(className,level).includes(r.armor));assert(r.itemLevel<=level);}
 }
}
assert.deepEqual(M.armorFor('Hunter',20),['Cloth','Leather']);
assert(M.armorFor('Hunter',40).includes('Mail'));
assert(!M.armorFor('Hunter',60).includes('Plate'));
assert.deepEqual(M.armorFor('Priest',60),['Cloth']);
assert(M.armorFor('Warrior',40).includes('Plate'));
assert(M.filter(rows,{...base,profession:'Leatherworking',armor:'Leather'}).every(r=>r.profession==='Leatherworking'&&r.armor==='Leather'));
assert.equal(M.filter(rows,{...base,search:'no-such-item-unmatched'}).length,0);
const learned=M.build(data,{...base,learned:true}),held=M.build(data,{...base,held:30});
for(const r of learned.filter(r=>!r.purchase))assert.equal(r.route.net,0);
for(const r of held.filter(r=>r.favor===30&&!r.extraGoldUnknown))assert.equal(r.route.net,0);
assert(M.filter(rows,{...base,complete:true}).every(r=>r.total!=null));
// Exact mixed-crate optimization compared with brute force, with awkward target sizes.
const custom={items:{'11':{price:1,name:'A'},'12':{price:1,name:'B'}},crates:[
 {id:1,title:'A',favor:6,level:1,rewardStatus:'Documented',price:310,options:[{id:11,name:'A',qty:1,price:1}]},
 {id:2,title:'B',favor:10,level:1,rewardStatus:'Documented',price:514,options:[{id:12,name:'B',qty:1,price:1}]}],catalog:[]};
for(let target=1;target<=45;target++){
 custom.catalog=[{id:3,name:'target',profession:'x',favor:target,reagents:[]}];
 const route=M.build(custom,base)[0].route;let min=Infinity;
 for(let a=0;a<12;a++)for(let b=0;b<12;b++)if(a*6+b*10>=target)min=Math.min(min,a*11+b*15);
 assert.equal(route.net,min);
}
console.log(`PASS: ${rows.length} entries; ${rows.filter(r=>r.total!=null).length} complete; net/upfront arithmetic, missing data, all nine class filters at 20/39/40/60, profession/type/search, held Favor, learned recipes, optimizer vs brute force.`);
// UI number inputs can temporarily be out of range; filters and routes must agree.
for(const level of [-10,0,39.9,100,Infinity]){
 const normalized=M.normalizeLevel(level);
 assert.deepEqual(M.filter(rows,{...base,className:'Hunter',level}),M.filter(rows,{...base,className:'Hunter',level:normalized}));
}
for(const price of [Infinity,NaN,'100',0,-1]){
 const d=structuredClone(custom);d.crates[0].price=price;d.crates[1].price=price;
 assert(M.build(d,base)[0].route.error);
}
const missingItem=structuredClone(custom);missingItem.catalog[0].reagents=[{id:999999,quantity:1}];
assert.equal(M.build(missingItem,base)[0].total,null);
custom.catalog[0].favor=10001;assert(M.build(custom,base)[0].route.error);
custom.catalog[0].favor=Infinity;assert(M.build(custom,base)[0].route.error);
console.log('PASS: normalized levels, invalid quotes, absent item metadata and bounded HTML targets.');
