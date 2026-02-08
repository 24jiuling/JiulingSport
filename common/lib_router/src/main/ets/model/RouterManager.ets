

export class RouterManager {
  private static instance: RouterManager;
  public navPathStack: NavPathStack = new NavPathStack();

  private constructor() {
  }

  public static getInstance(): RouterManager {
    if (!RouterManager.instance) {
      RouterManager.instance = new RouterManager();
    }
    return RouterManager.instance;
  }

  public getStack(): NavPathStack {
    return this.navPathStack;
  }

  public push(name: string, param?: Object): void {
    this.navPathStack.pushPath({ name: name, param: param });
  }

  public replace(name: string, param?: Object): void {
    this.navPathStack.replacePath({ name: name, param: param });
  }

  public pop(result?: Object): void {
    this.navPathStack.pop(result);
  }
}
