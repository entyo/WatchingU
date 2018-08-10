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
