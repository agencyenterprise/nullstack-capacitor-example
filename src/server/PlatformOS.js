class PlatformOS {
  static IOS = new PlatformOS('ios').name;
  static Android = new PlatformOS('android').name;

  constructor(name) {
    this.name = name;
  }
}