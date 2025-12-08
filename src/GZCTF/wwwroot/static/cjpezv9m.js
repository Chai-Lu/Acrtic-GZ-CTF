/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{t as e}from"./nugqs812.js";import{Ca as t,Jr as n,O as r,Oa as i,Vr as a,di as o,dr as s,ha as c,jr as l,li as u,pi as d}from"./index.hrqptwjo.js";var f=i(r()),p=i(t()),m=i(c());const h=t=>{let[r,i]=(0,p.useState)(!1),[c,h]=(0,p.useState)(!1),{t:g}=s();return(0,m.jsxs)(d,{shadow:`md`,width:`max-content`,position:`top`,opened:r,onChange:i,children:[(0,m.jsx)(d.Target,{children:(0,m.jsx)(o,{color:t.color,onClick:()=>i(!0),disabled:t.disabled&&!c,size:t.size,loading:c,children:(0,m.jsx)(f.Icon,{path:t.iconPath,size:t.size??1})})}),(0,m.jsx)(d.Dropdown,{children:(0,m.jsxs)(l,{align:`center`,gap:6,children:[(0,m.jsx)(n,{size:`sm`,fw:`bold`,h:`auto`,ta:`center`,className:e.wsPreWrap,children:t.message}),(0,m.jsxs)(u,{w:`100%`,justify:`space-between`,children:[(0,m.jsx)(a,{size:`xs`,py:2,variant:`outline`,disabled:t.disabled,onClick:()=>i(!1),children:g(`common.modal.cancel`)}),(0,m.jsx)(a,{size:`xs`,py:2,color:t.color,disabled:t.disabled&&!c,loading:c,onClick:()=>{h(!0),t.onClick().finally(()=>{h(!1),i(!1)})},children:g(`common.modal.confirm`)})]})]})})]})};export{h as t};