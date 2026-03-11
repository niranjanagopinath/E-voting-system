import React from 'react';
import { Vote, CheckCircle, Shield, Award, Users, Key } from 'lucide-react';
import './FloatingBackground.css';

const FloatingBackground = () => {
    const icons = [
        { Icon: Vote, size: 24, color: 'rgba(15, 118, 110, 0.1)' },
        { Icon: CheckCircle, size: 32, color: 'rgba(15, 118, 110, 0.08)' },
        { Icon: Shield, size: 28, color: 'rgba(15, 118, 110, 0.12)' },
        { Icon: Award, size: 40, color: 'rgba(15, 118, 110, 0.06)' },
        { Icon: Users, size: 24, color: 'rgba(15, 118, 110, 0.09)' },
        { Icon: Key, size: 20, color: 'rgba(15, 118, 110, 0.11)' },
        { Icon: Vote, size: 36, color: 'rgba(15, 118, 110, 0.07)' },
        { Icon: CheckCircle, size: 24, color: 'rgba(15, 118, 110, 0.13)' },
        { Icon: Shield, size: 48, color: 'rgba(15, 118, 110, 0.05)' },
        { Icon: Award, size: 28, color: 'rgba(15, 118, 110, 0.1)' },
        { Icon: Users, size: 32, color: 'rgba(15, 118, 110, 0.08)' },
        { Icon: Key, size: 44, color: 'rgba(15, 118, 110, 0.06)' },
    ];

    return (
        <div className="floating-background">
            <div className="mesh-gradient"></div>
            <div className="floating-icons-container">
                {icons.map(({ Icon, size, color }, index) => {
                    const style = {
                        left: `${Math.random() * 100}%`,
                        top: `${Math.random() * 100}%`,
                        animationDelay: `${Math.random() * 10}s`,
                        animationDuration: `${15 + Math.random() * 15}s`,
                        color: color,
                    };
                    return (
                        <div key={index} className="floating-icon" style={style}>
                            <Icon size={size} />
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default FloatingBackground;
