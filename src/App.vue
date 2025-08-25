<template>
  <TresCanvas shadows alpha clear-color="#001" ref="canvas">
    <TresPerspectiveCamera  :position="[100,30,50]" ref="cam"/>
    
     <OrbitControls ref="orbit" v-if="!started"/>


    <TresMesh :position="[0, 0, 10]">
      <TresCylinderGeometry :args="[.1, .1, 16]" />
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh>
      <TresCylinderGeometry :args="[.1, .1, 16]" />
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI / 2" :position="[0, 0, 10]">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#000" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI / 2">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#907" />
    </TresMesh>
    <TresMesh :rotation-x="Math.PI / 2" :position="[0, 0, 10]">
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

    <Hex x="0" y="0" color="#444" @selected="w => { selected = w }" />

    <Hex v-for="h of [[1, 0], [-1, 0], [1, -1], [-1, 1], [0, -1], [0, 1]]" :x="h[0]" :y="h[1]" @selected="w => { selected = w }"
      color="#a95" />

    <Hex v-for="h of [[-1, -1], [-1, 2],
    [0, -2], [0, 2],
    [1, -2], [1, 1],
    [2, 0], [2, -1], [2, -2],
    [-2, 0], [-2, 1], [-2, 2]
    ]" :x="h[0]" :y="h[1]" @selected="w => { selected = w }" color="#999" />

    <TresGridHelper v-if="grid" :args="[188, 128]" />

    <TresDirectionalLight :position="[0, 20000, 8000]" :intensity="1.2" cast-shadow />
  </TresCanvas>
  <div class="overlay">
    &#x2692; meine welt
  </div>
  <div class="overlay bottom-right" @click="grid = !grid">
    <!-- <button @click.stop.prevent="grid=!grid">*</button> -->
    <span style="font-size:4em;"> * </span>
  </div>
  <div class="overlay bottom-left" @click="start()">
    <pre>
p : [ {{ +$refs.orbit?.instance.object.position.x.toFixed(3) ?? '' }} , {{ +$refs.orbit?.instance.object.position.y.toFixed(3) ?? '' }} , {{ +$refs.orbit?.instance.object.position.z.toFixed(3) ?? '' }} ]
<!-- r : ( {{ +$refs.orbit?.instance.object.rotation.x.toFixed(3) }} , {{ +$refs.orbit?.instance.object.rotation.y.toFixed(3) }} , {{ +$refs.orbit?.instance.object.rotation.x.toFixed(z) }} ) -->
<!-- q : ( {{ +$refs.orbit?.instance.object.quaternion.x.toFixed(3) }} / {{ +$refs.orbit?.instance.object.quaternion.y.toFixed(3) }}/{{ $refs.orbit?.instance.object.quaternion.z.toFixed(3) }} / {{ +$refs.orbit?.instance.object.quaternion.w.toFixed(3) }} ) -->
<!-- <template v-if="grid">props:{{ Object.keys($refs.orbit?.instance.object ?? {}) }}</template> -->
</pre>
    <pre>s: {{ selected }}</pre>
    <pre>o: {{ objects }}</pre>
    <pre>
  f:{{ moveForward }}
  b:{{ moveBackward }}
  l:{{ moveLeft }}
  r:{{ moveRight }}
  ⏩:{{ moveFast }}
</pre>
    <pre>
  (click) {{ (started ? '(click)' : 'start') }}
</pre>
  </div>
</template>

<script>

import { TresCanvas } from '@tresjs/core';
import AnimatedCube from './AnimatedCube.vue';
import AnimatedSphere from './AnimatedSphere.vue';
import { OrbitControls, /*PointerLockControls, Superformula*/ } from '@tresjs/cientos'
import * as THREE from 'three'
import Hex from './Hex.vue';
import { PointerLockControls } from 'three/addons/controls/PointerLockControls.js';

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
      fps: 0,
      trees: [],
      growingStart: null,
      growingStop: false,
      wood: [],
      selected: null,
      grid: false,
      me: { x: 10, y: 6, z: 10 },
      started: false,
      moveForward: false,
      moveBackward: false,
      moveLeft: false,
      moveRight: false,
      moveFast: false,
      canJump: false,
      objects: [],
      velocity: new THREE.Vector3(),
      direction: new THREE.Vector3(),
      prevTime: performance.now(),
      raycaster: new THREE.Raycaster(new THREE.Vector3(), new THREE.Vector3(0, - 1, 0), 0, 10),
      //orbits:null,
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
      return this.trees.map(({ size }) => Math.pow(.2 * size, 2) * 2 * size).reduce((sum, s) => sum + s, 0);
    },
    me() {
      return { ...this.$refs.me }
    }
  },
  methods: {
    start() {

      // console.debug('start, orbit:', Object.keys(this.$refs.orbit.instance));
      // console.debug('start, orbit:', this.$refs.orbit.instance);

      // this.$refs.orbit.instance.enabled=false;

      console.debug('start', this.$refs.canvas.context.renderer)
      this.$refs.canvas.context.renderer.value.setAnimationLoop(null);

      this.started = !this.started;

      if (this.started) {

        let controls = new PointerLockControls( this.$refs.cam, document.body );
          controls.addEventListener('unlock', () => {
          console.debug('evt unlock');
          this.started = false;
        });
        controls.lock();

        this.$refs.canvas.context.renderer.value.setAnimationLoop(d => {

          if (this.started === true) {
            
            console.debug('set starting point', controls);

            controls.object.position.x = 10;
            controls.object.position.y = 12;
            controls.object.position.z = 10;
          }

          const time = performance.now();

          this.raycaster.ray.origin.copy(controls.object.position);
          this.raycaster.ray.origin.y -= 10;

          const intersections = this.raycaster.intersectObjects(this.objects, false);

          const onObject = intersections.length > 0;

          const delta = (time - this.prevTime) / 10000;

          // console.log('delta', delta);

          this.velocity.x -= this.velocity.x * 10.0 * delta;
          this.velocity.z -= this.velocity.z * 10.0 * delta;

          this.velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass
          // this.velocity.y = 0;

          this.direction.z = (Number(this.moveForward) - Number(this.moveBackward));
          this.direction.x = (Number(this.moveRight) - Number(this.moveLeft));
          this.direction.normalize(); // this ensures consistent movements in all directions

          // if (this.moveFast) {

          // }
          // this.

          if (this.moveForward || this.moveBackward) this.velocity.z -= this.direction.z * 400.0 * delta * (this.moveFast?8:1);
          if (this.moveLeft || this.moveRight) this.velocity.x -= this.direction.x * 400.0 * delta * (this.moveFast?8:1);

          // console.debug('move v', this.velocity.x, this.velocity.y,  this.velocity.z, 'dir y', this.direction.y,'pos', controls.object.position.x, controls.object.position.y, controls.object.position.z);

          if (onObject === true) {

            this.velocity.y = Math.max(0, this.velocity.y);
            this.canJump = true;

          }

          controls.moveRight(- this.velocity.x * delta);
          controls.moveForward(- this.velocity.z * delta);

          controls.object.position.y += (this.velocity.y * delta); // new behavior

          if (controls.object.position.y < 4) {

            this.velocity.y = 0;

            controls.object.position.y = 4;

            this.canJump = true;

          }

          this.started = d;
          this.prevTime = time
        })
      }
    }
  },
  created() {

  },
  mounted() {
    const onKeyDown = (event) => {

      console.debug('dn', event);

      switch (event.code) {

        case 'KeyE':
          this.moveFast = true;
          break;

        case 'ArrowUp':
        case 'KeyW':
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
          if (this.canJump === true) this.velocity.y += 350;
          this.canJump = false;
          break;

      }

    };

    const onKeyUp = (event) => {

      switch (event.code) {

        case 'KeyE':
          this.moveFast = false;
          break;

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

    document.addEventListener('keydown', onKeyDown);
    document.addEventListener('keyup', onKeyUp);
  }
}
</script>

<style scoped>
.overlay {
  position: fixed;
  top: 0;
  left: 0;
  color: white;
  max-height: 100vh;
  overflow-y: auto;
  padding: 1em;
  background-color: #0004;
}

.overlay.bottom-right {
  top: auto;
  left: auto;
  right: 0;
  bottom: 0;
}

.overlay.bottom-left {
  top: auto;
  bottom: 0;
}

.overlay button {
  font-size: 3em;
  padding-left: .5em;
  padding-right: .5em;
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
