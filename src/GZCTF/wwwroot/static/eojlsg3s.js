/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Ca as e,Jr as t,Oa as n,Ti as r,Wi as i,ha as a}from"./index.hrqptwjo.js";var o={container:`Ac`,text:`Bc`,textWrapper:`Cc`,clone:`Dc`,scroll:`Ec`},s=n(e()),c=n(a());const l=({text:e,onClick:n,size:a,speedCharPerSec:l=3.2,...u})=>{let d=(0,s.useRef)(null),f=(0,s.useRef)(null),[p,m]=(0,s.useState)(!1),[h,g]=(0,s.useState)(!1),[_,v]=(0,s.useState)(4),y=(0,s.useCallback)(()=>{if(h)return;let e=d.current,t=f.current;if(!e||!t)return;let n=parseFloat(getComputedStyle(t).fontSize||`14`)||14,r=t.scrollWidth;if(r-e.clientWidth>0){let e=r/(l*n);v(Math.max(3,e)),m(!0)}g(!0)},[h,l]);return(0,c.jsx)(r,{ref:d,className:o.container,onClick:n,onMouseEnter:y,"data-scroll":p||void 0,__vars:{"--scroll-time":`${_}s`},...u,children:(0,c.jsxs)(`div`,{className:o.textWrapper,children:[(0,c.jsx)(t,{ref:f,className:o.text,title:e,fz:a,children:e}),p&&(0,c.jsx)(t,{className:i(o.text,o.clone),fz:a,"aria-hidden":!0,children:e})]})})};export{l as t};