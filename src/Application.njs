import Nullstack from 'nullstack';
import { registerPlugin } from '@capacitor/core';

const Echo = registerPlugin('Echo');
const MortaroPlugin = registerPlugin('Mortaro');

class Application extends Nullstack {

  async echoTest() {
    const { value } = await Echo.echo({ value: 'Hello World!' });
    alert('Response from native:' + value);
  }

  async mortaroTest() {
    const { value } = await MortaroPlugin.sayHello();
  }

  prepare({ page }) {
    page.locale = 'en-US';
  }

  render() {
    return (
      <main>
        <button onclick={this.mortaroTest}> Click here to Toast </button>
        <br></br>
        <button onclick={this.echoTest}> Click here to Alert </button>
      </main>
    )
  }

}

export default Application;