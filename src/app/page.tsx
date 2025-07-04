export default function Home() {
  return (
    <div style={{ padding: '2rem', textAlign: 'center', fontFamily: 'system-ui' }}>
      <h1>Aux API Server</h1>
      <p>This server provides API endpoints for the Aux iOS app.</p>
      <p>
        <a href="/api-docs" style={{ color: '#0070f3' }}>View API Documentation</a>
      </p>
    </div>
  );
}