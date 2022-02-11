import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';
import { acknowledgePurchase, fetchSubscriptions } from './server/google-api'

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

  async handleSubscriptionByDevice({ purchase, platform }) {
    const IOS = 'ios';
    const ANDROID = 'android';

    if (platform === ANDROID) {
      this.processAndroidSubscription({ purchase: purchase.zzc.nameValuePairs });
    } else if (platform === IOS){
      this.processIosSubscription(purchase);
    } else {
      console.log('Unknown opering system!')
    }
  }

  async subscribe() {
    AppSubscriptionPlugin.addListener('onSubscriptionPurchased', (info) => {
      this.handleSubscriptionByDevice(info)
    });

    await AppSubscriptionPlugin.subscribe({ productId: 'google_api' });
  }

  static async processAndroidSubscription({ purchase }) {
    if (!purchase) {
      console.log('Purchase cannot be null');
      return;
    }
    try {
      const result = await acknowledgePurchase(purchase);
      console.log(result);
    } catch(e) {
      console.log(e);
    }
  }

  static async processIosSubscription({ purchase }) {
    // TODO: needs to be implemented
    console.log('Processing IOS purchase...');
  }

  async getSubscriptions() {
    this.subscriptions();
  }

  static async subscriptions() {
    try {
      const result = await fetchSubscriptions({ packageName: process.env.PROJECT_PACKAGE_NAME });
      console.log(result.data.inappproduct);
    } catch(e) {
      console.log(e);
    }
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
        <button onclick={this.getSubscriptions}> Get subscriptions </button>
      </main>
    )
  }

}

export default Application;
