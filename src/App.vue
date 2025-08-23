<template>
  <TresCanvas clear-color="#001" ref="canvas" >
    <TresPerspectiveCamera />
    <!-- :position="[13,13, 13]" :look-at="[0, 0, 0]" -->
     <OrbitControls />
    <TresMesh>
      <TresCylinderGeometry :args="[.1, .1, 10]" />
      <TresMeshToonMaterial color="#F03" />
    </TresMesh>
    <TresMesh :rotation-z="Math.PI/2">
      <TresCylinderGeometry :args="[.1, .1, 130]" />
      <TresMeshToonMaterial color="#0F3" />
    </TresMesh>
    <TresMesh :rotation-x="Math.PI/2">
      <TresCylinderGeometry :args="[.1, .1, 130]" />
      <TresMeshToonMaterial color="#03F" />
    </TresMesh>

    <!-- <TresMesh  :position="[0,-.05,10]">
      <TresBoxGeometry :args="[128,.1,148]"/>
      <TresMeshToonMaterial color="#630" />
    </TresMesh> -->
    <TresMesh :rotation-x="Math.PI / 2" >
      <TresExtrudeGeometry :args="[hexFloor]" />
      <TresMeshToonMaterial color="#630" />
    </TresMesh>

    <TresMesh :position="[0,5,0]">
      <TresBufferGeometry />
      <TresMeshToonMaterial color="#ff0" />
    </TresMesh>

    <GrowingTree v-for="(t,i) of trees"
      @treeClicked="t=>treeClicked(t)"
      :model-value="t" @fallen="handleFallen(t)/*wood.push({size:t.size, x:t.x, z:t.z })*/"
      :key="t.uuid"
    />
    <!-- <Wood v-for="l of wood"
      :model-value="t"
    /> -->
    <!-- @click="evt=>{evt.stopPropagation();treeClicked(t)}" -->
    <!-- <TresGroup v-for="t of trees" :position="[t.x, 0, t.z]" @click="d=>treeClicked(t, d)" >
      <template v-if="t.type == 'decidious'">
        <TresMesh :position="[0,1.5*t.size,0]">
          <TresSphereGeometry :args="[t.size]" />
          <TresMeshToonMaterial :color="t.color??'#090'" />
        </TresMesh>
        <TresMesh :position="[0, .25 * t.size,0]" >
            <TresCylinderGeometry :args="[.2 * t.size, .2 * t.size, .5 * t.size ]"/>
          <TresMeshToonMaterial color="#f90" />
        </TresMesh>
      </template>
      <template v-else>
        <TresMesh :position="[0,1.5*t.size,0]">
          <TresCylinderGeometry :args="[.1 * t.size, t.size, 2 * t.size ]"/>
          <TresMeshToonMaterial :color="t.color??'#090'" />
        </TresMesh>
        <TresMesh :position="[0,.25 * t.size,0]" >
            <TresCylinderGeometry :args="[.2 * t.size, .2 * t.size, .5 * t.size ]"/>
          <TresMeshToonMaterial color="#f90" />
        </TresMesh>
      </template>
    </TresGroup> -->

    <TresGridHelper :args="[128, 128]" />

    <TresDirectionalLight :position="[0, 2, 4]" :intensity="1.2" cast-shadow />
  </TresCanvas>
   <!-- <div class="overlay">
      FPS : {{ +fps.toFixed(2) }}
   </div> -->
   <div class="overlay">
      {{ +trees.length }} / {{ +totalWood.toFixed(2) }}
   </div>
   <div class="overlay bottom-right">
    <button @click.stop.prevent="addTree">+</button>
   </div>
   <div class="overlay bottom-left">
    <pre>{{ trees.filter(t=>t.color == '#a00') }}</pre>
   </div>
</template>

<script>

import { TresCanvas, useLoop } from '@tresjs/core';
import AnimatedCube from './AnimatedCube.vue';
import AnimatedSphere from './AnimatedSphere.vue';
import GrowingTree from './GrowingTree.vue';
import { OrbitControls, PointerLockControls, Superformula } from '@tresjs/cientos'
import * as THREE from 'three'


export default {
  setup() {
    // const { onBeforeRender } = useLoop();
    // return { onBeforeRender }
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
    GrowingTree,
  },
  computed: {
    totalWood() {
        return this.trees.map(({size})=>Math.pow(.2*size, 2)*2*size).reduce((sum,s)=>sum+s, 0);
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
        //await new Promise((res,rej)=>setTimeout(()=>res(), 200));
      }
      console.debug('forest created');
    },
    addTree() {

      const createNewTree = () => ({
            type: Math.random() > .5 ? 'decidious' : 'conifer',
            size: 2 +(Math.random()*5),
            // size: 5,
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
      // const isOff = ({x,z}) => {
      //   return ((z) > (x + 110)/2)
      //     || ((z) < (x - 110)/2)
      // }

      const offsetColor = ({x,z}) => {
        if ((z) > (x + 145) * (Math.sqrt(3)/3) && x < 0) return '#00b'; // blue
        if ((z) < (x - 110) * (Math.sqrt(3)/3) && x > 0) return '#0bb'; //turqoise
        if ((z) < (x + 110) * (Math.sqrt(3)/-3)) return '#bb0'; //yellow
        if ((z) > (x - 145) * (Math.sqrt(3)/-3)) return '#b70'; //orange
      };

      let tries = 0;
      while ((this.trees.find(t=>(intersects(t,newTree))) || offsetColor(newTree)) && tries < 100) {
        // console.debug('collision detected');
        newTree = createNewTree();
        tries++;
      }
      if (!(this.trees.find(t=>(intersects(t,newTree))) || offsetColor(newTree))) {
        // newTree.color = offsetColor(newTree); //isOff(newTree) ? '#00b' : undefined;
        this.trees.push(newTree);
        newTree.color= offsetColor(newTree);
        return newTree;
      }
      else {
        console.debug('more than 100 tries');
        // console.error('more than 100 tries');
        return undefined;
      }
    },
    treeClicked(tree) {
      // console.debug('treeclicked', tree, evt);
      // evt.stopPropagation();
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
        // if (!growing) {
        //   return
        // }
      }
    },
    handleFallen(t) {
      let spliced = this.trees.toSpliced(this.trees.indexOf(t), 1);
      this.trees = [];
      this.$nextTick(()=>{this.trees = spliced;});
      
    },
  },
  mounted() {

    this.createForest().then(()=>{
      console.debug('starting growing Loop');
      this.growingTreeLoop().then(()=>{
        console.debug('growing finished');
      });
    });

    console.debug('mounted finished');

    // this.onBeforeRender(({delta, elapsed})=>{
    //   for (const tree of this.trees) {
    //     // tree.size *= 1 /*+ delta*/;
    //   }
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
}
#app {
  height: 100%;
  width: 100%;
  background-color: #004;
}
</style>
