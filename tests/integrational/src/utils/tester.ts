export class Tester {
  tests: Function[] = [];

  public addTest(name: string, test: Function, isAsync: boolean = true) {
    this.tests.push({
      name,
      isAsync,
      test
    })
  }

  public async runTests(WS, settings) {
    for ({name, isAsync, test} of this.tests) {
      console.log(`Starting ${name} test...`);
      try {
        const res = await test(WS, settings);
        console.log(`${name} test done: ${res}`);
      } catch(err) {
        console.log(`${name} test failed with error: ${err}`);
      }
    }
  }
}














