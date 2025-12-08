/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Br as e,Li as t,Mi as n,Oa as r,Wi as i,ha as a,li as o,va as s}from"./index.hrqptwjo.js";var c={bar:`Ua`,pulse:`Va`,box:`Wa`,back:`Xa`,spikes:`Ya`,spike:`Za`,l:`_c`,r:`-c`,t:`ac`,b:`bc`},l=r(a());const u=r=>{let{thickness:a=4,spikeLength:u=250,percentage:d,color:f,...p}=r,m=t(),{colorScheme:h}=n(),g=d<100,_=g?h===`dark`?`light`:f??m.primaryColor:`gray`,v=m.colors[_][5],y=m.colors[_][2];return(0,l.jsx)(e,{py:a*u/100,...p,__vars:{"--thickness":s(a),"--spike-length":`${u}%`,"--neg-spike-length":`${-u}%`,"--percentage":`${d}%`,"--spike-color":v,"--bg-color":y,"--pulsing-display":g?`block`:`none`},children:(0,l.jsx)(`div`,{className:c.back,children:(0,l.jsxs)(o,{justify:`right`,className:c.box,children:[(0,l.jsx)(`div`,{className:c.bar,children:(0,l.jsx)(`div`,{})}),(0,l.jsxs)(`div`,{className:c.spikes,children:[(0,l.jsx)(`div`,{className:i(c.spike,c.r)}),(0,l.jsx)(`div`,{className:i(c.spike,c.l)}),(0,l.jsx)(`div`,{className:i(c.spike,c.t)}),(0,l.jsx)(`div`,{className:i(c.spike,c.b)})]})]})})})};export{u as t};