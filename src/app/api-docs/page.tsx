'use client';

export default function ApiDocsPage() {
  return (
    <div style={{ width: '100vw', height: '100vh', margin: 0, padding: 0 }}>
      <iframe 
        src="/api-docs.html" 
        style={{ width: '100%', height: '100%', border: 'none' }}
        title="API Documentation"
      />
    </div>
  );
}