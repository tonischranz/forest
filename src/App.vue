<template>
  <TresCanvas clear-color="#001" ref="canvas" >
    <TresPerspectiveCamera :position="[160, 64, 160]" ref="cam" />
    <!-- <TresPerspectiveCamera :position="()=>[me.x, me.y, me.z]" ref="cam" /> -->

    <!-- <PointerLockControls /> -->
     <PointerLockControls v-if="!grid" />
     <OrbitControls v-if="grid" />

     <TresMesh :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 75]"/>
      <TresMeshToonMaterial color="#000" />
    </TresMesh>
    <TresMesh :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 75]"/>
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh>
      <TresCylinderGeometry :args="[.1, .1, 75]"/>
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI/2" :position="[0,0,10]">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#F03" />
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
        console.debug('start');
        $refs.cam.position.x=10;
        $refs.cam.position.y=6;
        $refs.cam.position.z=10;
      }"
    >
    <pre>{{ selected }}</pre>
    <pre>{{ $refs.cam?.position }}</pre>
    <pre>{{ Object.keys($refs.canvas.context) }}</pre>
    <pre>{{ $refs.canvas.context.renderer }}</pre>
     <pre>{{ Object.keys($refs.canvas).join() }}</pre>
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
      grid:true,
      me:{x:10, y:6,z:10},
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
  },
  created() {
    
  },
  mounted() {
    console.debug('renderer', this.$refs.canvas);
    // this.createForest();
    // this.growingTreeLoop().then(()=>{
    //   console.debug('growing finished');
    // });
    // this.$refs.canvas.context.renderer.setAnimationLoop((d,e)=>{
    //   console.debug ('anim', d,e)
    //   this.$refs.cam.poisition.x += 1;
    //   this.$refs.cam.poisition.z += 1;
    // })
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
