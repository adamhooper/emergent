(function(e){typeof define=="function"&&define.amd?define(["moment"],e):typeof exports=="object"?module.exports=e(require("../moment")):e(window.moment)})(function(e){return e.defineLocale("gl",{months:"Xaneiro_Febreiro_Marzo_Abril_Maio_Xuño_Xullo_Agosto_Setembro_Outubro_Novembro_Decembro".split("_"),monthsShort:"Xan._Feb._Mar._Abr._Mai._Xuñ._Xul._Ago._Set._Out._Nov._Dec.".split("_"),weekdays:"Domingo_Luns_Martes_Mércores_Xoves_Venres_Sábado".split("_"),weekdaysShort:"Dom._Lun._Mar._Mér._Xov._Ven._Sáb.".split("_"),weekdaysMin:"Do_Lu_Ma_Mé_Xo_Ve_Sá".split("_"),longDateFormat:{LT:"H:mm",L:"DD/MM/YYYY",LL:"D MMMM YYYY",LLL:"D MMMM YYYY LT",LLLL:"dddd D MMMM YYYY LT"},calendar:{sameDay:function(){return"[hoxe "+(this.hours()!==1?"ás":"á")+"] LT"},nextDay:function(){return"[mañá "+(this.hours()!==1?"ás":"á")+"] LT"},nextWeek:function(){return"dddd ["+(this.hours()!==1?"ás":"a")+"] LT"},lastDay:function(){return"[onte "+(this.hours()!==1?"á":"a")+"] LT"},lastWeek:function(){return"[o] dddd [pasado "+(this.hours()!==1?"ás":"a")+"] LT"},sameElse:"L"},relativeTime:{future:function(e){return e==="uns segundos"?"nuns segundos":"en "+e},past:"hai %s",s:"uns segundos",m:"un minuto",mm:"%d minutos",h:"unha hora",hh:"%d horas",d:"un día",dd:"%d días",M:"un mes",MM:"%d meses",y:"un ano",yy:"%d anos"},ordinal:"%dº",week:{dow:1,doy:7}})});