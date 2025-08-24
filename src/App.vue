<template >
  <TresCanvas clear-color="#001" ref="canvas" >
    <TresPerspectiveCamera :position="[160, 64, 160]" ref="cam" />
    
     <OrbitControls ref="ctrl" />

     
    <TresMesh :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 16]"/>
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh>
      <TresCylinderGeometry :args="[.1, .1, 16]"/>
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI/2" :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#000" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI/2">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#907" />
    </TresMesh>
    <TresMesh :rotation-x="Math.PI/2" :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#03F" />
    </TresMesh>

    <!-- <TresMesh :rotation-x="Math.PI / 2" >
      <TresExtrudeGeometry :args="[hexFloor]" />
      <TresMeshToonMaterial color="#630" />
    </TresMesh> -->

    <!-- <TresMesh :position="[0,5,0]">
      <TresBufferGeometry />
      <TresMeshToonMaterial color="#ff0" />
    </TresMesh> -->

    <Hex x="0" y="0" color="#444" @selected="w=>{selected=w}" />

    <Hex v-for="h of [[1,0],[-1,0],[1,-1],[-1,1],[0,-1],[0,1]]" 
      :x="h[0]" 
      :y="h[1]"
      @selected="w=>{selected=w}"
      color="#a95" />

    <Hex v-for="h of [[-1,-1],[-1,2],
                    [0,-2],[0,2],
                    [1,-2],[1,1],
                    [2,0],[2,-1],[2,-2],
                    [-2,0],[-2,1],[-2,2]
                    ]" 
      :x="h[0]" 
      :y="h[1]"
      @selected="w=>{selected=w}"
      color="#999" />
    
    <TresGridHelper v-if="grid" :args="[188, 128]" />

    <TresDirectionalLight :position="[0, 20000, 8000]" :intensity="1.2" cast-shadow />
  </TresCanvas>
   <div class="overlay">
        &#x2692; meine welt
   </div>
   <div class="overlay bottom-right">
    <button @click.stop.prevent="grid=!grid">*</button>
   </div>
   <div class="overlay bottom-left"
      @click="() => {
        started=!started;
        if (started) {
          start();
        }
        }"
      >
      <pre>
p : [ {{ +$refs.ctrl?.instance.object.position.x.toFixed(3)??'' }} , {{ +$refs.ctrl?.instance.object.position.y.toFixed(3)??'' }} , {{ +$refs.ctrl?.instance.object.position.z.toFixed(3)??'' }} ]
r : ( {{ +$refs.ctrl?.instance.object.rotation.x.toFixed(3) }} , {{ +$refs.ctrl?.instance.object.rotation.y.toFixed(3) }} , {{ +$refs.ctrl?.instance.object.rotation.x.toFixed(z) }} )
q : ( {{ +$refs.ctrl?.instance.object.quaternion.x.toFixed(3) }} / {{ +$refs.ctrl?.instance.object.quaternion.y.toFixed(3) }}/{{ $refs.ctrl?.instance.object.quaternion.z.toFixed(3) }} / {{ +$refs.ctrl?.instance.object.quaternion.w.toFixed(3) }} )
<template v-if="grid">props:{{ Object.keys($refs.ctrl?.instance.object??{}) }}</template>
      </pre>
      <pre>{{ selected }}</pre>
      <pre>
f:{{ moveForward }}
b:{{ moveBackward }}
l:{{ moveLeft }}
r:{{ moveRight }}
      </pre>
      <pre>
        {{ (started?'stop':'start') }}
      </pre>
   </div>
</template>

<script>

import { TresCanvas } from '@tresjs/core';
import AnimatedCube from './AnimatedCube.vue';
import AnimatedSphere from './AnimatedSphere.vue';
import { OrbitControls, PointerLockControls, Superformula } from '@tresjs/cientos'
import * as THREE from 'three'
import Hex from './Hex.vue';

export default {
  setup() {
    let hexFloor = new THREE.Shape();
    hexFloor.moveTo(-64, -27);
    hexFloor.lineTo(0, -64);
    hexFloor.lineTo(64, -27);
    hexFloor.lineTo(64, 47);
    hexFloor.lineTo(0, 84);
    hexFloor.lineTo(-64, 47);
    hexFloor.lineTo(-64, -27);
    return { hexFloor };
  },
  data() {
    return {
      started: Date.now(),
      fps:0,
      trees: [],
      growingStart:null,
      growingStop: false,
      wood: [],
      selected:null,
      grid:false,
      me:{x:10, y:6,z:10},
      started:false,
      moveForward : false,
			moveBackward : false,
			moveLeft : false,
			moveRight : false,
			canJump : false,
    }
  },
  components: {
    TresCanvas,
    AnimatedCube,
    AnimatedSphere,
    OrbitControls,
    PointerLockControls,
    // GrowingTree,
    Hex,
  },
  computed: {
    totalWood() {
        return this.trees.map(({size})=>Math.pow(.2*size, 2)*2*size).reduce((sum,s)=>sum+s, 0);
    },
    me() {
      return {...this.$refs.me}
    }
  },
  methods: {
    start() {
      const onKeyDown = ( event ) => {
        console.debug('kdo', event.code );

					switch ( event.code ) {

						case 'ArrowUp':
						case 'KeyW':
              console.debug('fwd');
							this.moveForward = true;
							break;

						case 'ArrowLeft':
						case 'KeyA':
							this.moveLeft = true;
							break;

						case 'ArrowDown':
						case 'KeyS':
							this.moveBackward = true;
							break;

						case 'ArrowRight':
						case 'KeyD':
							this.moveRight = true;
							break;

						case 'Space':
							if ( this.canJump === true ) velocity.y += 350;
							this.canJump = false;
							break;

					}

				};

				const onKeyUp = ( event ) => {
          console.debug('kup', event.code );

					switch ( event.code ) {

						case 'ArrowUp':
						case 'KeyW':
							this.moveForward = false;
							break;

						case 'ArrowLeft':
						case 'KeyA':
							this.moveLeft = false;
							break;

						case 'ArrowDown':
						case 'KeyS':
							this.moveBackward = false;
							break;

						case 'ArrowRight':
						case 'KeyD':
							this.moveRight = false;
							break;

					}
        };

      document.addEventListener( 'keydown', onKeyDown );
			document.addEventListener( 'keyup', onKeyUp );

      this.$refs.ctrl.instance.object.position.x=10;
      this.$refs.ctrl.instance.object.position.y=6;
      this.$refs.ctrl.instance.object.position.z=10;

      this.$refs.canvas.context.renderer._value.setAnimationLoop(null);

        this.$refs.canvas.context.renderer._value.setAnimationLoop(d=>{
          

          if (this.$refs.ctrl.instance.object && this.started){
              
              this.$refs.ctrl.instance.object.position.x+=d/100000;
            
          }
        })
    }
  },
  created() {
    
  },
  mounted() {

  }
}
</script>

<style scoped>
.overlay {
  position:fixed;
  top:0;
  left:0;
  color:white;
  max-height: 100vh;
  overflow-y: auto;
  padding:1em;
  background-color: #0004;
}

.overlay.bottom-right {
  top:auto;
  left:auto;
  right:0;
  bottom:0;
}

.overlay.bottom-left {
  top:auto;
  bottom:0;
}

.overlay button {
  font-size: 3em;
  padding-left:.5em;
  padding-right:.5em;
}

</style>


<style>
html,
body {
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
  font-family: sans-serif;
}
#app {
  height: 100%;
  width: 100%;
  background-color: #004;
}
</style>
