/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Ca as e,Oa as t,Qi as n,Zi as r,ha as i,ji as a}from"./index.hrqptwjo.js";var o=t(i(),1),s=t(e(),1),c={multiple:!1},l=(0,s.forwardRef)((e,t)=>{let{onChange:i,children:l,multiple:u,accept:d,name:f,form:p,resetRef:m,disabled:h,capture:g,inputProps:_,...v}=a(`FileButton`,c,e),y=(0,s.useRef)(null),b=()=>{!h&&y.current?.click()};return r(m,()=>{y.current&&(y.current.value=``)}),(0,o.jsxs)(o.Fragment,{children:[(0,o.jsx)(`input`,{style:{display:`none`},type:`file`,accept:d,multiple:u,onChange:e=>{if(e.currentTarget.files===null)return i(u?[]:null);i(u?Array.from(e.currentTarget.files):e.currentTarget.files[0]||null)},ref:n(t,y),name:f,form:p,capture:g,..._}),l({onClick:b,...v})]})});l.displayName=`@mantine/core/FileButton`;export{l as t};