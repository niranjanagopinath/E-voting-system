import React, { useState, useEffect } from 'react';
import { resultsAPI, mockDataAPI } from '../services/api';
import './ResultsDashboard.css';

function ResultsDashboard() {
  const [results, setResults] = useState(null);
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadResults();
  }, []);

  const loadResults = async () => {
    setLoading(true);
    setError(null);
    try {
      const stats = await mockDataAPI.getElectionStats();
      const electionId = stats.data.election.id;
      
      try {
        const resultData = await resultsAPI.getByElectionId(electionId);
        setResults(resultData.data);
        
        const summaryData = await resultsAPI.getSummary(electionId);
        setSummary(summaryData.data);
      } catch (err) {
        setError('No results yet. Please run tallying process.');
      }
    } catch (err) {
      setError('Failed to load election data');
    }
    setLoading(false);
  };

  const verifyResults = async () => {
    if (!results) return;
    try {
      const verification = await resultsAPI.verify(results.election_id);
      alert(`Verification: ${verification.data.is_valid ? '✅ Valid' : '❌ Invalid'}`);
    } catch (err) {
      alert('Verification failed: ' + err.message);
    }
  };

  if (loading) return <div className="loading"><div className="spinner"></div>Loading results...</div>;
  if (error) return <div className="error-message">{error}</div>;
  if (!results) return (
    <div className="empty-state">
      <div className="empty-icon">📊</div>
      <h3>No results available yet</h3>
      <p>Start by going to the Testing tab and running the workflow</p>
    </div>
  );

  return (
    <div className="results-dashboard">
      <div className="dashboard-header">
        <h2>📊 Election Results</h2>
        {summary && (
          <div className="election-info">
            <div>
              <h3 className="election-title">{summary.election?.title || 'Unknown Election'}</h3>
              <span className={`status-badge status-${summary.election?.status || 'pending'}`}>
                {summary.election?.status || 'Pending'}
              </span>
            </div>
            <div className="vote-count">
              <span className="count-label">Total Votes</span>
              <span className="count-value">{summary.results?.total_votes || 0}</span>
            </div>
          </div>
        )}
      </div>
      
      <div className="results-content">
        <h3 className="section-title">🏆 Vote Distribution</h3>
        <div className="candidates-list">
          {summary && Object.entries(summary.results?.tally || {}).map(([candidate, data]) => (
            <div key={candidate} className="candidate-card">
              <div className="candidate-info">
                <span className="candidate-name">{candidate}</span>
                <span className="candidate-votes">{data.votes} votes ({data.percentage}%)</span>
              </div>
              <div className="vote-bar-container">
                <div
                  className="vote-bar-fill"
                  style={{ width: `${data.percentage}%` }}
                />
              </div>
            </div>
          ))}
        </div>

        <div className="verification-section">
          <h3 className="section-title">🔐 Verification Details</h3>
          <div className="verification-grid">
            <div className="verification-item">
              <span className="label">Verification Hash</span>
              <span className="value hash">{results.verification_hash?.substring(0, 32)}...</span>
            </div>
            <div className="verification-item">
              <span className="label">Status</span>
              <span className="value">{results.is_verified ? '✅ Verified' : '⏳ Pending'}</span>
            </div>
            {summary?.blockchain?.published && (
              <div className="verification-item">
                <span className="label">Blockchain TX</span>
                <span className="value hash">{summary.blockchain.tx_hash?.substring(0, 32)}...</span>
              </div>
            )}
          </div>
        </div>

        <div className="actions-section">
          <button className="btn btn-primary" onClick={verifyResults}>
            🔍 Verify Results
          </button>
          <button className="btn btn-secondary" onClick={loadResults}>
            🔄 Refresh
          </button>
        </div>
      </div>
    </div>
  );
}

export default ResultsDashboard;
