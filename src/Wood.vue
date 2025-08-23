<template>
    <TresGroup :position="[modelValue.x, 0, modelValue.z]" 
      @click="({stopPropagation})=>{stopPropagation();$emit('woodClicked', modelValue)}"
      ref="wholeTree"
      :rotate-x="Math.PI/2"
    >
      <TresMesh :position="[0, 1 * modelValue.size,-.22*modelValue.size]" >
            <TresCylinderGeometry :args="[.2 * modelValue.size, .2 * modelValue.size, 2 * modelValue.size ]"/>
          <TresMeshToonMaterial color="#851" />
      </TresMesh>
    </TresGroup>
</template>

<script>

export default {
   
    props: {
        modelValue: Object,
    },
    emits: ['woodClicked'],
    mounted() {
    },
}


</script>