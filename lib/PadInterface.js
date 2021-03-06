//~ var ws281x = require('rpi-ws281x-native');

class PadInterface {
	constructor(numLEDs) {
		this.state = 'off'
		this.numLEDs = numLEDs;
		this.brightness = 128;
		this.pixelData = new Uint32Array(numLEDs);

		
		//~ ws281x.init(numLEDs);
	}
	
	getPadState() {
		return this.state;
	}

	color(r, g, b){
		
		r = r * this.brightness / 255;
		g = g * this.brightness / 255;
		b = b * this.brightness / 255;
		return ((r & 0xFF) << 16) + ((g & 0xFF) << 8) + (b & 0xFF);
	}

	green() {
		
		if(this.state != 'green') {
			console.log("Turning pad green");
			this.state = 'green';
			//~ var pixelData = this.pixelData;
			//~ for(var i = 0; i < this.numLEDs; i++){
				//~ pixelData[i] = this.color(0, 255, 0); 
			//~ }
			//~ ws281x.render(pixelData)
			//~ this.pixelData = pixelData;
		}
	}
	
	blue() {
		
		if(this.state != 'blue') {
			console.log("Turning pad blue");
			this.state = 'blue';
			//~ var pixelData = this.pixelData;
			//~ for(var i = 0; i < this.numLEDs; i++){
				//~ pixelData[i] = this.color(0, 0, 255); 
			//~ }
			//~ ws281x.render(pixelData);
			//~ this.pixelData = pixelData;
		}
	}
	
	gold() {
		
		if(this.state != 'gold') {
			console.log("Turning pad gold");
			this.state = 'gold';
			//~ var pixelData = this.pixelData;
			//~ for(var i = 0; i < this.numLEDs; i++){
				//~ pixelData[i] = this.color(255, 215, 0); 
			//~ }
			//~ ws281x.render(pixelData);
			//~ this.pixelData = pixelData;
		}
	}
	
	purple() {
		
		if(this.state != 'purple') {
			console.log("Turning pad purple");
			this.state = 'purple';
			//~ var pixelData = this.pixelData;
			//~ for(var i = 0; i < this.numLEDs; i++){
				//~ pixelData[i] = this.color(255, 51, 153); 
			//~ }
			//~ ws281x.render(pixelData);
			//~ this.pixelData = pixelData;
		}
	}

	red() {
		
		if(this.state != 'red') {
			console.log("Turning pad red");
			this.state = 'red';
			//~ var pixelData = this.pixelData;
			//~ for(var i = 0; i < this.numLEDs; i++){
				//~ pixelData[i] = this.color(255, 0, 0); 
			//~ }
			//~ ws281x.render(pixelData);
			//~ this.pixelData = pixelData;
		}
	}

	lightsOff() {
		for(var i = 0; i < NUM_LEDS; i++){
			pixelData[i] = this.color(0, 0, 0); 
		}
		//ws281x.render(pixelData);
		ws281x.reset();
	}
}


module.exports = PadInterface;
