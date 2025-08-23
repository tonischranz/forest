<template>
    <TresGroup :position="[((x*136)+(y * 68)),0,(y*118)]">
        <TresMesh :rotation-x="Math.PI / 2" >
        <TresExtrudeGeometry :args="[hexFloor]" />
        <TresMeshToonMaterial :color="color" />
        </TresMesh>
        <Tree v-for="(t,i) of trees"
            :model-value="t"
            @fallen="handleFallen(t)"
            :key="t.uuid"
            />
    </TresGroup>
</template>

<script>

import Tree from './Tree.vue';
import * as THREE from 'three';

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
        trees:[]
    }
  },
  props: {
    x:Number,
    y:Number,
    color:String,
  },
  components: {
    Tree,
  },
  methods:{
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

      const isOffset = ({x,z}) =>
        ((z) > (x + 145) * (Math.sqrt(3)/3) && x < 0)
        ||((z) < (x - 110) * (Math.sqrt(3)/3) && x > 0)
        ||((z) < (x + 110) * (Math.sqrt(3)/-3))
        || ((z) > (x - 145) * (Math.sqrt(3)/-3));

      let tries = 0;
      while ((this.trees.find(t=>(intersects(t,newTree))) || isOffset(newTree)) && tries < 100) {
        newTree = createNewTree();
        tries++;
      }
      if (!(this.trees.find(t=>(intersects(t,newTree))) || isOffset(newTree))) {
        this.trees.push(newTree);
        return newTree;
      }
      else {
        console.debug('more than 100 tries');
        return undefined;
      }
    },
    handleFallen(t) {
      let spliced = this.trees.toSpliced(this.trees.indexOf(t), 1);
      this.trees = [];
      this.$nextTick(()=>{this.trees = spliced;});
      
    },
  },
  mounted() {
    for (let i = 0; i < 32; i++) {
        this.addTree();
    }
  }
}
</script>