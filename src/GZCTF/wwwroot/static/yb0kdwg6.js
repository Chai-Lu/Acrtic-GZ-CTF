/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{E as e,Li as t,Oa as n,dr as r,ha as i,li as a}from"./index.hrqptwjo.js";import{t as o}from"./cjpezv9m.js";var s=n(i());const c=n=>{let{disabled:i,participation:c,setParticipation:l,size:u,...d}=n,f=e(),p=f.get(c.status),m=t(),{t:h}=r();return(0,s.jsx)(a,{wrap:`nowrap`,justify:`center`,mx:`xs`,miw:`calc(${m.spacing.xl} * 2)`,...d,children:p.transformTo.map(e=>{let t=f.get(e);return(0,s.jsx)(o,{size:u,iconPath:t.iconPath,color:t.color,message:h(`admin.content.games.review.participation.update`,{status:t.title}),disabled:i,onClick:()=>l(c.id,{status:e,divisionId:c.divisionId})},`${c.id}@${e}`)})})};var l={root:`v_`,item:`w_`,label:`x_`,control:`y_`};export{c as n,l as t};