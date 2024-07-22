let Hooks = {}

Hooks.FadeIn = {
  mounted() {
    console.log('mounted')
    this.el.classList.add('opacity-0', 'hidden');
    setTimeout(() => {
      this.el.classList.remove('opacity-0', 'hidden');
      this.el.classList.add("opacity-100");
    }, 300);
  }
}

export default Hooks;
