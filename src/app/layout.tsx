import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Aux - Universal Playlist Converter",
  description: "Convert playlists between Spotify and Apple Music seamlessly. Never miss out on great music again.",
  icons: {
    icon: '/favicon.ico',
    apple: '/favicon.ico',
  },
  openGraph: {
    title: 'Aux - Universal Playlist Converter',
    description: 'Convert playlists between Spotify and Apple Music seamlessly',
    url: 'https://aux-50dr.onrender.com',
    siteName: 'Aux',
    type: 'website',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}