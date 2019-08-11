import {App} from "./../core/facade";

const getUrlVar = function(name){
  return App.Utils.getUrlVars()[name];
}

export default getUrlVar;
