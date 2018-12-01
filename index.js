import "./style.scss"

if (process.env.NODE_ENV === "production") {
  require("./built.js");
} else {
  function main() {
    require("./output/Main").main();
  }
  
  if (module.hot) {
    module.hot.dispose(function() {
      console.log("dispose");
    });
  
    module.hot.accept(function() {
      console.log("accept");
      document.body.innerHTML = ''
      main();
    });
  }
  
  main();
}