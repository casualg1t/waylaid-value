(function(root){
  'use strict';
  const normalizeLevel=value=>Math.max(1,Math.min(60,Math.floor(Number(value)||20)));
  const validPrice=value=>typeof value==='number'&&Number.isFinite(value)&&value>0;
  function build(data,settings){
    const level=normalizeLevel(settings.level);
    const held=Math.max(0,Math.min(10000,Math.floor(Number(settings.held)||0)));
    const choices=data.crates.filter(c=>c.rewardStatus==='Documented'&&c.level<=level&&validPrice(c.price)).map(c=>{
      const options=c.options.filter(o=>validPrice(o.price)).map(o=>({...o,total:o.quantity?o.quantity*o.price:o.qty*o.price})).sort((a,b)=>a.total-b.total||a.id-b.id);
      if(!options.length)return null;
      const gross=c.price+options[0].total,silver=c.favor*50;
      return {crate:c,best:options[0],gross,silver,net:gross-silver,missing:c.options.length-options.length};
    }).filter(Boolean);
    const unsafe=choices.some(c=>c.net<=0);
    const max=Math.max(1,...choices.map(c=>c.crate.favor));
    const targetMax=Math.max(0,...data.catalog.map(r=>Math.max(0,(settings.learned&&!r.purchase?0:r.favor||0)-held)));
    const cap=Math.min(10000,targetMax)+max-1,cost=Array(cap+1).fill(Infinity),from=[],picked=[];cost[0]=0;
    if(!unsafe)for(let s=1;s<=cap;s++)for(let i=0;i<choices.length;i++){
      const c=choices[i],prev=s-c.crate.favor;
      if(prev>=0&&cost[prev]+c.net<cost[s]){cost[s]=cost[prev]+c.net;from[s]=prev;picked[s]=i;}
    }
    function plan(target){
      if(target===0)return {net:0,gross:0,silver:0,favor:0,steps:[]};
      if(!Number.isFinite(target)||target>10000)return {error:'Favor target exceeds 10,000.'};
      if(unsafe)return {error:'A zero or negative net crate quote needs verification.'};
      let best=-1;
      for(let s=target;s<=Math.min(cap,target+max-1);s++)if(Number.isFinite(cost[s])&&(best<0||cost[s]<cost[best]))best=s;
      if(best<0)return {error:'No complete, eligible crate price combination.'};
      const result={net:cost[best],gross:0,silver:0,favor:best,steps:[]},groups=new Map();
      for(let s=best;s>0;s=from[s]){
        const c=choices[picked[s]];if(!groups.has(c.crate.id))groups.set(c.crate.id,{...c,count:0});groups.get(c.crate.id).count++;
        result.gross+=c.gross;result.silver+=c.silver;
      }
      result.steps=[...groups.values()];return result;
    }
    return data.catalog.map(r=>{
      const favor=settings.learned&&!r.purchase?0:r.favor;
      const needed=favor==null?null:Math.max(0,favor-held),route=needed==null?{error:'Recipe Favor cost not verified.'}:plan(needed);
      const reagents=(r.reagents||[]).map(x=>({...x,item:data.items[String(x.id)],total:validPrice(data.items[String(x.id)]?.price)?data.items[String(x.id)].price*x.quantity:null}));
      const missing=reagents.filter(x=>x.total==null).length;
      const materials=r.reagents==null||missing?null:reagents.reduce((n,x)=>n+x.total,0);
      const total=route.error||materials==null||r.extraGoldUnknown?null:route.net+materials;
      return {...r,route,needed,reagents,craftDataMissing:r.reagents==null,missing,materials,total,upfront:total==null?null:route.gross+materials,leftover:route.error||favor==null?null:held+route.favor-favor};
    });
  }
  function armorFor(cls,level){
    if(['Priest','Mage','Warlock'].includes(cls))return ['Cloth'];
    if(['Rogue','Druid'].includes(cls))return ['Cloth','Leather'];
    if(['Hunter','Shaman'].includes(cls))return level>=40?['Cloth','Leather','Mail']:['Cloth','Leather'];
    if(['Warrior','Paladin'].includes(cls))return level>=40?['Cloth','Leather','Mail','Plate']:['Cloth','Leather','Mail'];
    return [];
  }
  function filter(rows,s){
    const query=(s.search||'').toLowerCase().trim(),level=normalizeLevel(s.level);
    const allowed=armorFor(s.className,level);
    return rows.filter(r=>{
      if(query&&!`${r.name} ${r.profession}`.toLowerCase().includes(query))return false;
      if(s.profession&&r.profession!==s.profession)return false;
      if(s.armor&&r.armor!==s.armor)return false;
      if(s.className&&(!allowed.includes(r.armor)||r.itemLevel>level||(r.classes&&!r.classes.includes(s.className))))return false;
      if(s.complete&&r.total==null)return false;
      return true;
    }).sort((a,b)=>s.sort==='name'?a.name.localeCompare(b.name):s.sort==='favor'?(a.favor??Infinity)-(b.favor??Infinity)||a.name.localeCompare(b.name):(a.total??Infinity)-(b.total??Infinity)||a.name.localeCompare(b.name));
  }
  const api={build,filter,armorFor,normalizeLevel};
  if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.RewardsModel=api;
})(typeof window!=='undefined'?window:globalThis);
