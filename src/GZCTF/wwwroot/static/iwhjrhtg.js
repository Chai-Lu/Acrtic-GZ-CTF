/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{i as e}from"./lcut4z52.js";import{Br as t,Ca as n,Jn as r,Oa as i,fi as a,ha as o,or as s,sr as c}from"./index.hrqptwjo.js";var l=i(n()),u=i(o());const d=new Map([[r.Admin,3],[r.Monitor,1],[r.User,0],[r.Banned,-1]]),f=(e,t)=>d.get(t??r.User)>=d.get(e),p=({requiredRole:n,children:r})=>{let{role:i,error:o}=e(),f=c(),p=s(),m=d.get(n);return(0,l.useEffect)(()=>{o&&o.status===401&&f(`/account/login?from=${p.pathname}`,{replace:!0}),i&&d.get(i)<m&&f(`/404`)},[i,o,m,f]),i&&d.get(i)<m?(0,u.jsx)(t,{h:`calc(100vh - 32px)`,children:(0,u.jsx)(a,{})}):(0,u.jsx)(u.Fragment,{children:r})};export{p as n,f as t};