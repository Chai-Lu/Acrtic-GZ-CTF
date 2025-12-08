/* The GZ::CTF Project @unknown
 * 
 * License   : GNU Affero General Public License v3.0 (Core)
 * License   : LicenseRef-GZCTF-Restricted (Restricted components)
 * Commit    : Unofficial build version
 * Build     : 2025-12-08T11:45:34.456Z
 * Copyright (C) 2022-2025 GZTimeWalker. All Rights Reserved.
 */
import{Ca as e,Oa as t}from"./index.hrqptwjo.js";var n=t(e(),1);function r(e={timeout:2e3}){let[t,r]=(0,n.useState)(null),[i,a]=(0,n.useState)(!1),[o,s]=(0,n.useState)(null),c=t=>{window.clearTimeout(o),s(window.setTimeout(()=>a(!1),e.timeout)),a(t)};return{copy:e=>{`clipboard`in navigator?navigator.clipboard.writeText(e).then(()=>c(!0)).catch(e=>r(e)):r(Error(`useClipboard: navigator.clipboard is not supported`))},reset:()=>{a(!1),r(null),window.clearTimeout(o)},error:t,copied:i}}export{r as t};