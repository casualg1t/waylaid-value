// Execute the actual standalone report handlers. This is a DOM double, not rendering QA.
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const html=fs.readFileSync('outputs/wow-forever-rewards-costs.html','utf8');
const scripts=[...html.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/g)];
const data=JSON.parse(scripts.find(s=>s[1].includes('application/json'))[2]);
function run(data){
 const elements=new Map();
 function element(id){if(!elements.has(id))elements.set(id,{value:'',type:'text',checked:false,textContent:'',innerHTML:'',listeners:{},appendChild(){},addEventListener(e,f){this.listeners[e]=f;}});return elements.get(id);}
 element('market').textContent=JSON.stringify(data);
 const ctx={document:{getElementById:element,createElement:()=>({})}};ctx.window=ctx;
 vm.createContext(ctx);for(const s of scripts.filter(s=>!s[1].includes('application/json')))vm.runInContext(s[2],ctx);
 function input(id,value,type='text'){const e=element(id);e.value=value;e.type=type;if(type==='checkbox')e.checked=value;e.listeners[['search','level','held'].includes(id)?'input':'change']({target:e});}
 return {ctx,element,input};
}
let {ctx,element,input}=run(data);
assert(element('snapshot').textContent.includes(data.snapshot));
input('search','no-such-reward');assert(element('rows').innerHTML.includes('No rewards match'));
input('search','');input('level','100');input('className','Hunter');assert(element('filterNote').textContent.includes('level 60'));
input('className','');element('next').listeners.click();assert(element('pageInfo').textContent.includes('page 2'));
input('held','6000');assert(ctx.reportTest.rows.every(r=>r.needed==null||r.needed===0));
// Missing metadata must show an incomplete reagent, not crash the entire report.
const broken=structuredClone(data);broken.catalog=[{name:'Missing reagent',id:0,profession:'Test',favor:0,reagents:[{id:999999,quantity:1}]}];
({element}=run(broken));assert(element('rows').innerHTML.includes('Item #999999'));assert(element('rows').innerHTML.includes('Incomplete'));
console.log('PASS: generated report callbacks, pagination, snapshot label, normalized filter text and missing reagent rendering (DOM double).');
