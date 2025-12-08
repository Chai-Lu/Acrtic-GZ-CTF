/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Ca as e,In as t,Oa as n,jn as r}from"./index.hrqptwjo.js";var i=n(e());const a=(e,n)=>{let{data:i,error:a,mutate:o}=t.edit.useEditGetGameChallenge(e,n,r);return{challenge:i,error:a,mutate:o}},o=e=>{let{data:n,error:a,mutate:o}=t.edit.useEditGetGameChallenges(e,r),[s,c]=(0,i.useState)(null);return(0,i.useEffect)(()=>{n&&c(n.toSorted((e,t)=>(e.category??``)>(t.category??``)?-1:1))},[n]),{challenges:s,error:a,mutate:o}};export{o as n,a as t};