type Theme = 'light' | 'dark'

const applyTheme = (theme: Theme) => {
  document.documentElement.dataset.theme = theme
  localStorage.setItem('food-theme', theme)
}

export function initThemeToggle() {
  const saved = localStorage.getItem('food-theme') as Theme | null
  applyTheme(saved ?? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'))

  const toggle = document.createElement('button')
  toggle.className = 'theme-toggle'
  toggle.type = 'button'
  const render = () => { toggle.textContent = document.documentElement.dataset.theme === 'dark' ? '☀ Light' : '☾ Dark' }
  toggle.addEventListener('click', () => {
    applyTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark')
    render()
  })
  render()
  document.body.append(toggle)
}
