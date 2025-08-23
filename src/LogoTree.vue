<template>
    <TresGroup :position="[modelValue.x, 0, modelValue.z]" 
      @click="({stopPropagation})=>{stopPropagation();fallStarted=Date.now();$emit('treeClicked', modelValue)}"
      ref="wholeTree"
    >
      <TresMesh :position="[0, 1 * modelValue.size,0]" >
            <TresCylinderGeometry :args="[.2 * modelValue.size, .2 * modelValue.size, 2 * modelValue.size ]"/>
          <TresMeshToonMaterial color="#851" />
      </TresMesh>
      <template v-if="modelValue.type == 'decidious'">
        <TresMesh :position="[0,1.5*modelValue.size,0]">
          <TresSphereGeometry :args="[modelValue.size]" />
          <TresMeshToonMaterial :color="modelValue.color??'#090'" />
        </TresMesh>
      </template>
      <template v-else>
        <TresMesh :position="[0,1.5*modelValue.size,0]">
          <TresCylinderGeometry :args="[.1 * modelValue.size, modelValue.size, 2 * modelValue.size ]"/>
          <TresMeshToonMaterial :color="modelValue.color??'#090'" />
        </TresMesh>
      </template>
      <TresGroup v-if="modelValue.color == '#a00' && modelValue.size >= 5">
        <TresMesh  :position="[2.5,.5 * modelValue.size,0]" :rotate-x="Math.PI / 2" >
          <TresCylinderGeometry :args="[.75, .75, 7.5]"/>
          <TresMeshToonMaterial color="#971" />
        </TresMesh>
        <TresMesh  :position="[-2.5,.5 * modelValue.size,0]" :rotate-x="Math.PI / 2" >
          <TresCylinderGeometry :args="[.75, .75, 7.5]"/>
          <TresMeshToonMaterial color="#971" />
        </TresMesh>
        <TresMesh  :position="[0,.5 * modelValue.size,2.5]" :rotate-x="Math.PI / 2" :rotate-z="Math.PI / 2" >
          <TresCylinderGeometry :args="[.75, .75, 7.5]"/>
          <TresMeshToonMaterial color="#971" />
        </TresMesh>
        <TresMesh  :position="[0, .5 * modelValue.size,-2.5]" :rotate-x="Math.PI / 2" :rotate-z="Math.PI / 2">
          <TresCylinderGeometry :args="[.75, .75, 7.5]"/>
          <TresMeshToonMaterial color="#971" />
        </TresMesh>
        <TresMesh :position="[0,.5*modelValue.size, 0]">
          <TresBoxGeometry :args="[5, .5, 5]" />
          <TresMeshToonMaterial color="#a82" />
        </TresMesh>
      </TresGroup>
    <TresGroup :position="[0,2.625*modelValue.size+3.25,0]" ref="crone" :scale="[.125,-.125,.125]" >
      <TresGroup :position="[-15, 0, 0]" ref="tbd" :scale="[.5,.5,.5]" />
    </TresGroup>
    </TresGroup>
</template>

<script>

// import { TresGroup, TresMesh, TresMeshToonMaterial, TresCylinderGeometry, TresSphereGeometry } from '@tresjs/core';
// import Shape from 'three';
import { useLoop } from '@tresjs/core';
import * as THREE from 'three';
import { SVGLoader } from 'three/addons/loaders/SVGLoader.js';

export default {
    setup() {
      const { onBeforeRender } = useLoop();
      const loader = new SVGLoader();
      
      
      return { 
        onBeforeRender,
        loader
      };
    },
    data() {
      let s = new THREE.Shape();
      s.moveTo(0,0);
      s.lineTo(0,5);
      s.lineTo(5,0);
      s.lineTo(0,0);
      return {
        testShape: s,
        fallenDelta : 0
      }
    },
    props: {
        modelValue: Object,
    },
    emits: ['treeClicked'],
    mounted() {
      this.onBeforeRender(({ delta, elapsed }) => {
          //  this.$refs.crone.rotateY(delta);
          this.$refs.crone.rotateY(Math.random() * delta);

           if (this.fallStarted) {
            this.fallenDelta += delta; //Math.abs ((2 * delta) / this.modelValue.size);
            if (this.fallenDelta < Math.PI/2) {
              this.$refs.wholeTree.rotateX(delta);
            }
            else {
              this.$emit('fallen');
            }
           }
      })

      this.loader.load(Math.random() > .5 ?
        './TBD.svg':
        'multicolor.svg',
        (data) => {
          console.debug('svg loaded', data.xml.viewBox);
          const paths = data.paths;
          const group = this.$refs.tbd; // new THREE.Group();

          for ( let i = 0; i < paths.length; i ++ ) {

            const path = paths[ i ];
            // path.trans

            const material = new THREE.MeshBasicMaterial( {
              color: path.color,
              side: THREE.DoubleSide,
              depthWrite: false
            } );

            const shapes = SVGLoader.createShapes( path );

            for ( let j = 0; j < shapes.length; j ++ ) {

              const shape = shapes[ j ];
              const geometry = new THREE.ExtrudeGeometry( shape );
              const mesh = new THREE.Mesh( geometry, material );
              group.add( mesh );

            }
          }
        }
      )
    },
}


</script>