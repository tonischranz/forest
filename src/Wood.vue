<template>

    <TresMesh :position="[modelValue.x, 0, modelValue.z]">
      <TresCylinderGeometry :args="[.1, .1, 75]"/>
      <TresMeshToonMaterial color="#af3" />
    </TresMesh>

    <TresGroup :position="[modelValue.x, 0, modelValue.z]"
      @click="({stopPropagation})=>{
        stopPropagation();
        $emit('woodClicked', modelValue)}"
      :rotate-y="modelValue.orientation"
      :rotate-x="Math.PI/2"
    >
          <TresMesh :position="[0, 2 * modelValue.size,-.2*modelValue.size]" :rotate-x="Math.PI/2">
            <TresCylinderGeometry :args="[.1, .1, 75]"/>
          <TresMeshToonMaterial color="#a00" />
      </TresMesh>


      <TresMesh :position="[0, 1 * modelValue.size,-.2*modelValue.size]" >
            <TresCylinderGeometry :args="[.2 * modelValue.size, .2 * modelValue.size, 2 * modelValue.size ]"/>
          <TresMeshPhongMaterial color="#851" />
      </TresMesh>

    </TresGroup>
</template>

<script>

export default {
   
    props: {
        modelValue: Object,
    },
    computed: {
      
      endPos() {
        return [
          this.modelValue.x + ((2*this.modelValue.size)*Math.sin(this.modelValue.orientation)),
          0, 
          this.modelValue.z + (2*this.modelValue.size*Math.cos(this.modelValue.orientation))
        ];
      } 
    },
    emits: ['woodClicked'],
    methods:{
      endX(){
        console.debug('endX' ,this.modelValue.x)
        return this.modelValue.x + 2;
      },
      endZ(){
        return this.modelValue.z + 2;
      },
    },
    mounted() {
    },
}


</script>