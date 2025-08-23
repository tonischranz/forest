<template>
    <TresMesh :position="[0, -4, 5]" ref="sphere">
      <TresSphereGeometry />
       <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh>
    <primitive :object="cwmky" ref="cwmy" />
</template>

<script>


import { useLoop, useTexture, useLoader } from '@tresjs/core';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader';

export default {
    async setup() {
        const { onBeforeRender } = useLoop();
        const texture = await useTexture({
            map: '/bp-1920.png'
        });
        // const { scene }
        const cwmky = await useLoader(GLTFLoader, '/cubewithmonkey.glb');
        console.debug('cwmky', cwmky);
        return { onBeforeRender, texture, cwmky:cwmky.scene };
    },
    mounted() {
        this.onBeforeRender(({delta, elapsed})=>{

            this.$emit('fps', 1/delta);

            this.$refs.sphere.position.y += Math.sin(elapsed) / 10;

            this.$refs.cwmy.rotation.z += delta;

            this.$refs.cwmy.position.x = 0 + (Math.sin(elapsed) * 4);
            this.$refs.cwmy.position.z = 0 + (Math.cos(elapsed) * 4);
        })
    },
    emits: ['fps']
}
</script>