/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{m as e}from"./isy1dskq.js";import{n as t}from"./nugqs812.js";import{Ca as n,Li as r,Mi as i,Oa as a,Ti as o,ha as s,li as c}from"./index.hrqptwjo.js";var l={default:`sc`,inner:`tc`,label:`uc`,icon:`vc`,hidable:`wc`,panes:`xc`},u=a(n()),d=a(s()),f=e=>{let{color:t,label:n,active:r,icon:i,tabKey:a,disabled:s,...c}=e;return(0,d.jsx)(o,{...c,component:`button`,type:`button`,role:`tab`,disabled:s,__vars:{"--tab-active-color":t},"data-active":r||void 0,className:l.default,children:(0,d.jsxs)(`div`,{className:l.inner,children:[i&&(0,d.jsx)(`div`,{className:l.icon,children:i}),n&&(0,d.jsx)(`div`,{className:l.label,children:n})]})},a)};const p=n=>{let{active:a,onTabChange:o,tabs:s,withIcon:p,aside:m,disabled:h,...g}=n,[_,v]=(0,u.useState)(a??0),y=r(),{colorScheme:b}=i(),x=e=>e?y.colors[y.primaryColor][b===`dark`?4:6]:void 0,S=e(_,0,s.length-1);(0,u.useEffect)(()=>{v(a??0)},[a]);let C=s.map((e,t)=>(0,d.jsx)(f,{...e,disabled:h,color:x(e.color),active:S===t,onClick:()=>{v(t),o&&o(t,e.tabKey)}},e.tabKey));return(0,d.jsxs)(c,{gap:0,justify:`space-between`,w:`100%`,wrap:`nowrap`,children:[m,p&&(0,d.jsx)(t,{className:l.hidable}),(0,d.jsx)(c,{className:l.panes,...g,children:C})]})};export{p as t};