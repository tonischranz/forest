<template>
    <TresGroup :position="[modelValue.x, 0, modelValue.z]"
      :rotate-y="fallingOrientation" 
      @click="({stopPropagation})=>{
        stopPropagation();
        fallingOrientation=Math.random()*Math.PI*(Math.random()>.5?-1:1)
        fallStarted=Date.now();
        $emit('treeClicked', modelValue)}"
      @double-click="({stopPropagation})=>{
        stopPropagation();
        fallingOrientation=Math.random()*Math.PI*(Math.random()>.5?-1:1)
        fallStarted=Date.now();
        $emit('treeClicked', modelValue)}"
      ref="wholeTree"
      @context-menu="({stopPropagation})=>{
        stopPropagation();
        fallingOrientation=Math.random()*Math.PI*(Math.random()>.5?-1:1)
        fallStarted=Date.now();
        $emit('treeClicked', modelValue)}"
    >
    <!-- @click="({stopPropagation})=>{
        stopPropagation();
        fallingOrientation=Math.random()*Math.PI*(Math.random()>.5?-1:1)
        fallStarted=Date.now();
        $emit('treeClicked', modelValue)}" -->
      <TresMesh :position="[0, 1 * modelValue.size,0]" >
            <TresCylinderGeometry :args="[.2 * modelValue.size, .2 * modelValue.size, 2 * modelValue.size ]"/>
          <TresMeshPhongMaterial color="#851" />
      </TresMesh>
      <template v-if="modelValue.type == 'decidious'">
        <TresMesh :position="[0,1.5*modelValue.size,0]">
          <TresSphereGeometry :args="[modelValue.size]" />
           <TresMeshPhongMaterial :color="modelValue.color??'#090'" />
        </TresMesh>
      </template>
      <template v-else>
        <TresMesh :position="[0,1.5*modelValue.size,0]">
          <TresCylinderGeometry :args="[.1 * modelValue.size, modelValue.size, 2 * modelValue.size ]"/>
           <TresMeshPhongMaterial :color="modelValue.color??'#070'" />
        </TresMesh>
      </template>
    </TresGroup>
</template>

<script>

import { useLoop } from '@tresjs/core';

export default {
    setup() {
      const { onBeforeRender } = useLoop();
      
      return { 
        onBeforeRender,
      };
    },
    data() {
      return {
        fallenDelta : 0,
        fallingOrientation: 0,
      }
    },
    props: {
        modelValue: Object,
    },
    emits: ['treeClicked'],
    mounted() {
      this.onBeforeRender(({ delta, elapsed }) => {

           if (this.fallStarted) {
            this.fallenDelta += delta;
            if (this.fallenDelta < Math.PI/2) {
              this.$refs.wholeTree.rotateX(delta);
            }
            else {
              this.$emit('fallen', this.fallingOrientation);
            }
           }
      })
    },
}


</script>