import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';
import { acknowledgePurchase, fetchSubscriptions } from './server/manageSubscriptions'

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

  getSubscriptionId() {
    const MONTHLY_SUBSCRIPTION_ID = 'instill.monthly';
    const YEARLY_SUBSCRIPTION_ID = 'instill.yearly';

    const monthlyChecked = document.getElementById("monthly").checked;
    if (monthlyChecked) {
      return MONTHLY_SUBSCRIPTION_ID;
    }
    return YEARLY_SUBSCRIPTION_ID;
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
    try {
      const productId = this.getSubscriptionId()
      AppSubscriptionPlugin.addListener('onSubscriptionPurchased', (info) => {
        AppSubscriptionPlugin.removeAllListeners();
        this.handleSubscriptionByDevice(info)
      });

      await AppSubscriptionPlugin.subscribe({ productId });
    } catch(e) {
      AppSubscriptionPlugin.removeAllListeners();
      console.error(e);
    }
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
        <br></br><br></br><br></br>
        <button onclick={this.helloTest}> Click here to native Alert </button>
        <br></br>
        <button onclick={this.echoTest}> Click here to web Alert </button>
        <br></br><br></br><br></br><br></br>
        <button onclick={this.subscribe}> Click here to subscribe </button>

        <br></br><br></br>
        <div>
          <input type="radio" id="monthly" name="subscribe" value="MONTHLY" checked="true"> Monthly </input>
          <br></br><br></br>
          <input type="radio" id="yearly" name="subscribe" value="YEARLY"> Yearly </input>
        </div>

        <br></br><br></br><br></br>
        <button onclick={this.getSubscriptions}> Get Android subscriptions </button>
      </main>
    )
  }

}

export default Application;
