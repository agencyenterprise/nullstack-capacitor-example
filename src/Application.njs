import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';
import { Device } from '@capacitor/device';
import { acknowledgePurchase } from './server/google-api'

const Echo = registerPlugin('Echo');
const HelloPlugin = registerPlugin('Hello');
const AppSubscriptionPlugin = registerPlugin('AppSubscriptionPlugin');
class Application extends Nullstack {

  async echoTest() {
    const { value } = await Echo.echo({ value: 'Hello World!' });
    alert('Response from native:' + value);
  }

  async helloTest() {
    const { value } = await HelloPlugin.sayHello();
  }

  async handleSubscriptionByDevice(device) {
    if (device.platform === PlatformOS.Android) {
      this.processAndroidSubscription({ purchase: purchase.zzc.nameValuePairs });
    } else if (device.platform === PlatformOS.IOS){
      // TODO: needs to be defined
    } else {
      console.log('Unknown opering system!')
    }
  }

  async subscribe() {
    AppSubscriptionPlugin.addListener('onSubscriptionPurchased', (purchase) => {
      Device.getInfo()
      .then(this.handleSubscriptionByDevice)
      .catch(console.log);
    });

    await AppSubscriptionPlugin.subscribe({ productId: 'google_api' });
  }

  static async processAndroidSubscription({ purchase }) {
    try {
      const result = await acknowledgePurchase(purchase);
      console.log(result);
    } catch(e) {
      console.log(e);
    }
  }

  async testDeviceInfo() {
    Device.getInfo()
      .then(console.log)
      .catch(console.log);
  }

  prepare({ page }) {
    page.locale = 'en-US';
  }

  render() {
    return (
      <main>
        <button onclick={this.helloTest}> Click here to native Alert </button>
        <br></br>
        <button onclick={this.echoTest}> Click here to web Alert </button>
        <br></br><br></br><br></br><br></br>
        <button onclick={this.subscribe}> Click here to subscribe </button>

        <br></br><br></br><br></br><br></br>
        <button onclick={this.testDeviceInfo}> test device info </button>
      </main>
    )
  }

}

export default Application;
