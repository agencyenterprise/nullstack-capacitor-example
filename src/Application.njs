import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';

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

  async subscribe({ productId }) {
    AppSubscriptionPlugin.addListener('onSubscriptionPurchased', (purchase) => {
      this.processSubscription({ purchase: purchase.zzc.nameValuePairs });
    });

    await AppSubscriptionPlugin.subscribe({ productId: productId });
  }

  async subscribeYearly() {
    await this.subscribe({ productId: 'com.app.subscription.yearly'});
  }

  async subscribeMonthly() {
    await this.subscribe({ productId: 'com.app.subscription.monthly'});
  }

  static async processSubscription({ purchase }) {
    const {
      packageName,
      productId: subscriptionId,
      purchaseToken: token } = purchase
    console.log(`packageName : ${packageName}, subscriptionId: ${subscriptionId}, token: ${token}`);
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
        <button onclick={this.subscribeMonthly}> Click here to subscribe monthly </button>
        <br></br>
        <button onclick={this.subscribeYearly}> Click here to subscribe yearly </button>
      </main>
    )
  }

}

export default Application;
