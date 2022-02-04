import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';

const Echo = registerPlugin('Echo');
const HelloPlugin = registerPlugin('Hello');
const AppSubscription = registerPlugin('AppSubscription');

class Application extends Nullstack {

  async echoTest() {
    const { value } = await Echo.echo({ value: 'Hello World!' });
    alert('Response from native:' + value);
  }

  async helloTest() {
    const { value } = await HelloPlugin.sayHello();
  }

  async subscribe() {
    await AppSubscription.subscribe({ productId: 'gas' });
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
      </main>
    )
  }

}

export default Application;