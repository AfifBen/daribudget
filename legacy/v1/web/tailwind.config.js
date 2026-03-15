export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        forest: {
          950: '#071c16',
          900: '#0b2b22',
          800: '#10362b',
          700: '#134233',
          600: '#17503f',
          100: '#e5f2ed',
        },
        gold: {
          500: '#d8b45c',
          400: '#e4c77a',
          300: '#f0db9d',
        },
      },
      boxShadow: {
        soft: '0 20px 50px -30px rgba(0,0,0,0.45)',
      },
      borderRadius: {
        xl: '1.25rem',
        '2xl': '1.75rem',
      },
    },
  },
  plugins: [],
};
