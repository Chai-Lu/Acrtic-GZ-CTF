/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Ca as e,Ci as t,Gi as n,Oa as r,Pi as i,Ti as a,_i as o,ha as s,ji as c,ma as l,ua as u}from"./index.hrqptwjo.js";var d=r(e(),1),f=r(s(),1),[p,m]=l(`Card component was not found in tree`),h={root:`m_e615b15f`,section:`m_599a2148`},g=t((e,t)=>{let{classNames:n,className:r,style:i,styles:o,vars:s,withBorder:l,inheritPadding:u,mod:d,...p}=c(`CardSection`,null,e),h=m();return(0,f.jsx)(a,{ref:t,mod:[{"with-border":l,"inherit-padding":u},d],...h.getStyles(`section`,{className:r,style:i,styles:o,classNames:n}),...p})});g.classes=h,g.displayName=`@mantine/core/CardSection`;var _=n((e,{padding:t})=>({root:{"--card-padding":u(t)}})),v=t((e,t)=>{let n=c(`Card`,null,e),{classNames:r,className:a,style:s,styles:l,unstyled:u,vars:m,children:v,padding:y,attributes:b,...x}=n,S=i({name:`Card`,props:n,classes:h,className:a,style:s,classNames:r,styles:l,unstyled:u,attributes:b,vars:m,varsResolver:_}),C=d.Children.toArray(v),w=C.map((e,t)=>typeof e==`object`&&e&&`type`in e&&e.type===g?(0,d.cloneElement)(e,{"data-first-section":t===0||void 0,"data-last-section":t===C.length-1||void 0}):e);return(0,f.jsx)(p,{value:{getStyles:S},children:(0,f.jsx)(o,{ref:t,unstyled:u,...S(`root`),...x,children:w})})});v.classes=h,v.displayName=`@mantine/core/Card`,v.Section=g;export{v as t};