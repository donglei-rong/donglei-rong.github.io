// Progressive enhancements only: all content remains visible without JavaScript.
document.documentElement.classList.replace('no-js', 'js');
const nav = document.querySelector('#site-nav');
const toggle = document.querySelector('.nav-toggle');
if (nav && toggle) {
  toggle.hidden = false;
  const closeMenu = () => {
    nav.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
  };
  toggle.addEventListener('click', () => {
    const isOpen = nav.classList.toggle('is-open');
    toggle.setAttribute('aria-expanded', String(isOpen));
  });
  nav.querySelectorAll('a').forEach(link => link.addEventListener('click', closeMenu));
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && nav.classList.contains('is-open')) {
      closeMenu();
      toggle.focus();
    }
  });
}

const filters = document.querySelector('.publication-filters');
const publicationList = document.querySelector('#all-publications-list');
if (filters && publicationList) {
  filters.hidden = false;
  let year = 'all';
  const type = filters.querySelector('select');
  const buttons = [...filters.querySelectorAll('button[data-year]')];
  const items = [...publicationList.querySelectorAll('.publication')];
  const applyFilters = () => {
    let count = 0;
    items.forEach(item => {
      const matches = (year === 'all' || item.dataset.year === year)
        && (type.value === 'all' || item.dataset.type === type.value);
      item.hidden = !matches;
      if (matches) count++;
    });
    publicationList.querySelectorAll('[data-year-group]').forEach(group => {
      group.hidden = ![...group.querySelectorAll('.publication')].some(item => !item.hidden);
    });
    document.querySelector('.no-results').hidden = count > 0;
    document.querySelector('#publication-result').textContent = `${count} publication${count === 1 ? '' : 's'} shown`;
  };
  buttons.forEach(button => button.addEventListener('click', () => {
    year = button.dataset.year;
    buttons.forEach(item => item.setAttribute('aria-pressed', String(item === button)));
    applyFilters();
  }));
  type.addEventListener('change', applyFilters);
  applyFilters();
}

if ('IntersectionObserver' in window && nav) {
  const links = [...nav.querySelectorAll('a[href^="#"]')];
  const sections = links.map(link => document.querySelector(link.getAttribute('href'))).filter(Boolean);
  const observer = new IntersectionObserver(entries => {
    const visible = entries.filter(entry => entry.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
    if (!visible.length) return;
    links.forEach(link => {
      if (link.hash === `#${visible[0].target.id}`) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
  }, { rootMargin: '-15% 0px -65% 0px', threshold: 0 });
  sections.forEach(section => observer.observe(section));
}

