import './globals.css';

export const metadata = {
  title: 'Todo List',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
