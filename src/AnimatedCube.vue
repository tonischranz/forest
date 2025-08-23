<template>
    <TresMesh :position="[4, 4, 0]" :rotation-z="2" cast-shadow ref="cube">
      <TresBoxGeometry :args="[1.5, 1.5, 1.5]" />
      <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh>
    <!-- <TresMesh :position="[8, 0, 0]" :rotation-z="3" cast-shadow>
      <TresBoxGeometry :args="[3, 3, 1]" />
      <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh>
    <TresMesh :position="[-12, 0, 0]" cast-shadow>
      <TresBoxGeometry :args="[7, 7, 7]" />
      <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh>
        <TresMesh :position="[-5, 0, 0]" cast-shadow>
      <TresBoxGeometry :args="[7, 7, 7]" />
      <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh>
     <TresMesh :position="[-5, -7, 0]" cast-shadow>
      <TresBoxGeometry :args="[7, 7, 7]" />
      <TresMeshStandardMaterial :map="texture.map" />
    </TresMesh> -->
</template>

<script setup>
// import { useTresContext } from '@tresjs/core'
import { useLoader, useTexture } from '@tresjs/core';
import { useLoop } from '@tresjs/core';
import { shallowRef } from 'vue';
// import { TextureLoader } from 'three'

// const context = useTresContext();
const { onBeforeRender } = useLoop()
const cube = shallowRef();
const texture = await useTexture({
    map: '/cross.png'
})
// const texture = useLoader(TextureLoader, '/bp-1920.png')

onBeforeRender(({ delta, elapsed }) => {
    // console.debug('beforeRender', delta)
//   cube.value.rotation.y += delta
    cube.value.position.x = elapsed;
})
</script>