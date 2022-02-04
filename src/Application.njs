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

  async subscribe() {
    AppSubscriptionPlugin.addListener('subscriptionPurchased', (info) => {
      //TODO: Get the receipt from the local url in info["receiptUrl"]
      this.validateSubscription();
    });
    await AppSubscriptionPlugin.subscribe();
  }

  async isSubscribed() {
     await AppSubscriptionPlugin.isUserSubscribed();
  }

  static async validateSubscription() {
    //TODO: Validate the receipt and get its JSON response
    console.log("Transaction received");
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
        <button onclick={this.isSubscribed}> Is subscribed? </button>
      </main>
    )
  }

}

export default Application;
