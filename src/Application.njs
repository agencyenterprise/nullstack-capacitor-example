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

  retrieveSubscriptionTime() {
    const monthlyChecked = document.getElementById("monthly").checked
    if(monthlyChecked){
      return 'instill.monthly'
    }
    return 'instill.yearly'
  }

  async subscribe() {
    const pID = this.retrieveSubscriptionTime()
    AppSubscriptionPlugin.addListener('onSubscriptionPurchased', (purchase) => {
      this.processSubscription({ purchase: purchase.zzc.nameValuePairs });
    });
    await AppSubscriptionPlugin.subscribe({ productId: pID});
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
        <button onclick={this.subscribe}> Click here to subscribe </button>
        <br></br>
        <div>
        <input type="radio" id="monthly" name="subscribe_month" value="MONTHLY" checked="true"> Monthly </input>
        <br></br>
        <input type="radio" id="yearly" name="subscribe_year" value="YEARLY"> Yearly </input>
        </div>
      </main>
    )
  }

}

export default Application;
