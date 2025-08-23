<template>
  <TresCanvas clear-color="#001" ref="canvas" >
    <TresPerspectiveCamera  />

     <OrbitControls />
    <TresMesh>
      <TresCylinderGeometry :args="[.1, .1, 75]" />
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI/2">
      <TresCylinderGeometry :args="[.1, .1, 756]" />
      <TresMeshToonMaterial color="#F03" />
    </TresMesh>
    <TresMesh :rotation-x="Math.PI/2">
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

    <Hex x="0" y="0" color="#444" />
    
    <Hex x="1" y="0" color="#aa0" />
    <Hex x="-1" y="0" color="#0a0" />
    <Hex x="1" y="-1" color="#808" />
    <Hex x="-1" y="1" color="#0aa" />
    <Hex x="0" y="-1" color="#a70" />
    <Hex x="0" y="1" color="#a00" />

    <Hex x="-1" y="-1" color="#aaa" />
    <Hex x="0" y="-2" color="#aaa" />
    <Hex x="1" y="-2" color="#aaa" />
    <Hex x="1" y="1" color="#aaa" />
    <Hex x="2" y="0" color="#aaa" />
    <Hex x="2" y="-1" color="#aaa" />
    <Hex x="2" y="-2" color="#aaa" />
    <Hex x="0" y="2" color="#aaa" />
    <Hex x="-1" y="2" color="#999" />
    <Hex x="-2" y="1" color="#999" />
    <Hex x="-2" y="2" color="#999" />
    <Hex x="-2" y="0" color="#999" />
    
    <TresGridHelper :args="[128, 128]" />

    <TresDirectionalLight :position="[0, 2, 4]" :intensity="1.2" cast-shadow />
  </TresCanvas>
   <div class="overlay">
      {{ +trees.length }} / {{ +totalWood.toFixed(2) }}
   </div>
   <div class="overlay bottom-right">
    <button @click.stop.prevent="trees=[];createForest()">*</button>
   </div>
   <div class="overlay bottom-left">
    <pre></pre>
   </div>
</template>

<script>

import { TresCanvas, useLoop } from '@tresjs/core';
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
    async createForest() {
      let failed = 0;
      for (let i = 0 ; i < 2048 && failed < 100; i++) {
        let tree = this.addTree();
        if (!tree) {
          failed++
        }
      }
      console.debug('forest created');
    },
    addTree() {

      const createNewTree = () => ({
            type: Math.random() > .5 ? 'decidious' : 'conifer',
            size: 2 +(Math.random()*5),
            x: -64 + Math.random()*128,
            z: -64 + Math.random()*148,
            uuid: crypto.randomUUID(),
      });
      
      let newTree = createNewTree();

      const intersects = (a,b) => {
        let dst = Math.sqrt((Math.pow(a.x - b.x, 2)) + Math.pow(a.z - b.z,2));
        let minDistance = a.size + b.size;
        return dst < minDistance;
      }

      const offsetColor = ({x,z}) => {
        if ((z) > (x + 145) * (Math.sqrt(3)/3) && x < 0) return '#00b'; // blue
        if ((z) < (x - 110) * (Math.sqrt(3)/3) && x > 0) return '#0bb'; //turqoise
        if ((z) < (x + 110) * (Math.sqrt(3)/-3)) return '#bb0'; //yellow
        if ((z) > (x - 145) * (Math.sqrt(3)/-3)) return '#b70'; //orange
      };

      let tries = 0;
      while ((this.trees.find(t=>(intersects(t,newTree))) || offsetColor(newTree)) && tries < 100) {
        newTree = createNewTree();
        tries++;
      }
      if (!(this.trees.find(t=>(intersects(t,newTree))) || offsetColor(newTree))) {
        this.trees.push(newTree);
        newTree.color= offsetColor(newTree);
        return newTree;
      }
      else {
        console.debug('more than 100 tries');
        return undefined;
      }
    },
    treeClicked(tree) {
      if (!tree.color || tree.color != '#a00') {
        tree.color = '#a00';
      }
      else {
        delete tree.color;
      }
    },
    async growingTreeLoop() {
      this.growingStart = Date.now();
      this.growingStop = false;

      while(!this.growingStop) {
        await new Promise((res,rej)=>setTimeout(()=>res(), 200));
        let delta = Date.now() - this.growingStart;
        this.growingStart = Date.now();

        const intersects = (a,b) => {
          if (a == b) {
            return false;
          }
          let dst = Math.sqrt((Math.pow(a.x - b.x, 2)) + Math.pow(a.z - b.z,2));
          let minDistance = a.size + b.size - ((a.size + b.size) / 4);
          return dst < minDistance;
        }

        let growing = false;
        for (const tree of this.trees) {
          if (!this.trees.find(t=>intersects(t,tree))) {
            tree.size *= 1 + (delta /100000);
            growing = true;
          }
        }
      }
    },
    handleFallen(t) {
      let spliced = this.trees.toSpliced(this.trees.indexOf(t), 1);
      this.trees = [];
      this.$nextTick(()=>{this.trees = spliced;});
      
    },
  },
  created() {
    
  },
  mounted() {
    this.createForest();
    this.growingTreeLoop().then(()=>{
      console.debug('growing finished');
    });
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
}
#app {
  height: 100%;
  width: 100%;
  background-color: #004;
}
</style>
