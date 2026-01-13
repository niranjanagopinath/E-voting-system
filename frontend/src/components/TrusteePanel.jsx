import React, { useState, useEffect } from 'react';
import { trusteesAPI, tallyingAPI, mockDataAPI } from '../services/api';
import './TrusteePanel.css';

function TrusteePanel() {
  const [trustees, setTrustees] = useState([]);
  const [tallyStatus, setTallyStatus] = useState(null);
  const [electionId, setElectionId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    loadTrustees();
    loadElectionInfo();
  }, []);

  const loadTrustees = async () => {
    try {
      const response = await trusteesAPI.getAll();
      setTrustees(response.data);
    } catch (err) {
      console.error('Failed to load trustees:', err);
    }
  };

  const loadElectionInfo = async () => {
    try {
      const stats = await mockDataAPI.getElectionStats();
      setElectionId(stats.data.election.id);
      
      if (stats.data.tallying.started) {
        const status = await tallyingAPI.getStatus(stats.data.election.id);
        setTallyStatus(status.data);
      }
    } catch (err) {
      console.error('Failed to load election info:', err);
    }
  };

  const handlePartialDecrypt = async (trusteeId) => {
    if (!electionId) {
      alert('No election found');
      return;
    }

    setLoading(true);
    setMessage(null);
    try {
      const response = await tallyingAPI.partialDecrypt(trusteeId, electionId);
      setMessage({ type: 'success', text: response.data.message });
      await loadElectionInfo();
    } catch (err) {
      setMessage({ type: 'error', text: err.response?.data?.detail || 'Decryption failed' });
    }
    setLoading(false);
  };

  return (
    <div className="trustee-panel">
      <div className="card">
        <div className="panel-header">
          <h2>🔐 Trustees Panel</h2>
          <p className="threshold-info">Threshold: 3-of-5 trustees required for decryption</p>
        </div>

        {message && (
          <div className={`message ${message.type === 'success' ? 'message-success' : 'message-error'}`}>
            {message.text}
          </div>
        )}

        {tallyStatus && (
          <div className="status-box">
            <h3>📊 Tallying Status</h3>
            <div className="status-details">
              <p>Status: <strong className="status-value">{tallyStatus.status}</strong></p>
              <p>Progress: <strong className="status-value">{tallyStatus.completed_trustees}/{tallyStatus.required_trustees}</strong> trustees</p>
            </div>
          </div>
        )}

        <div className="trustees-section">
          <h3>👥 Registered Trustees</h3>
          {trustees.length === 0 ? (
            <div className="empty-state">
              <p>👤 No trustees registered</p>
            </div>
          ) : (
            <div className="table-container">
              <table className="trustees-table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Status</th>
                    <th className="action-col">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {trustees.slice(0, 5).map((trustee) => (
                    <tr key={trustee.trustee_id}>
                      <td className="trustee-name">{trustee.name}</td>
                      <td className="trustee-email">{trustee.email}</td>
                      <td>
                        <span className={`status-badge ${trustee.status === 'active' ? 'status-active' : 'status-inactive'}`}>
                          {trustee.status}
                        </span>
                      </td>
                      <td className="action-col">
                        <button
                          className="btn btn-primary btn-decrypt"
                          onClick={() => handlePartialDecrypt(trustee.trustee_id)}
                          disabled={loading || !tallyStatus}
                        >
                          {loading ? '⏳' : '🔓'} Decrypt
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default TrusteePanel;
