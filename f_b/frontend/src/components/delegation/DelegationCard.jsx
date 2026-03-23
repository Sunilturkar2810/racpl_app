import React from 'react';
import { useNavigate } from 'react-router-dom';

const DelegationCard = ({ delegation, user, isAdmin, onEdit, onDelete }) => {
    const navigate = useNavigate();

   
    const formatDate = (dateString) => {
        if (!dateString) return 'N/A';
        return new Date(dateString).toLocaleString('en-IN', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit', hour12: false
        });
    };

    const isOverdue = new Date(delegation.due_date) < new Date() && delegation.status !== 'COMPLETED';

    return (
        <div className="bg-bg-card rounded-xl overflow-hidden shadow-lg border border-border-main group hover:border-blue-500/50 transition-all font-sans relative">
            {/* Header Section */}
            <div className="p-4 flex items-start justify-between gap-4">
                <div className="flex items-start gap-4 flex-1 min-w-0 pr-28 sm:pr-32">
                    <div className="size-12 bg-yellow-400 rounded-xl flex items-center justify-center shrink-0 shadow-md shadow-yellow-400/20">
                        <span className="material-symbols-outlined text-black text-2xl">assignment</span>
                    </div>
                    <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-1.5 mb-1.5 flex-wrap">
                            <span className="text-text-muted font-bold text-[11px]">#{delegation.id}</span>
                            {isOverdue && (
                                <span className="bg-red-600 text-white text-[9px] font-bold px-1.5 py-0.5 rounded uppercase tracking-wider">Overdue</span>
                            )}
                            <span className={`px-1.5 py-0.5 rounded text-[9px] font-bold uppercase tracking-wider whitespace-nowrap ${delegation.status === 'COMPLETED' ? 'bg-emerald-500/20 text-emerald-500' :
                                delegation.status === 'NEED CLARITY' ? 'bg-amber-500/20 text-amber-500' :
                                    delegation.status === 'APPROVAL WAITING' ? 'bg-blue-500/20 text-blue-500' :
                                        'bg-slate-500/20 text-slate-500'
                                }`}>
                                {delegation.status}
                            </span>
                        </div>
                        <h3 className="text-text-main font-bold text-base sm:text-lg mb-1 truncate leading-tight" title={delegation.delegation_name || 'Untitled'}>{delegation.delegation_name || 'Untitled Section'}</h3>
                        <p className="text-text-muted text-[13px] sm:text-sm line-clamp-1">{delegation.description || 'No description provided.'}</p>
                    </div>
                </div>

                {/* Actions */}
                <div className="flex gap-1 absolute top-4 right-4 bg-bg-card/80 backdrop-blur-sm rounded-lg p-1 border border-border-main/50 shadow-sm">
                    <button onClick={() => navigate(`/delegation/${delegation.id}`)} className="text-text-muted hover:text-yellow-500 transition-colors p-1" title="View">
                        <span className="material-symbols-outlined text-xl">visibility</span>
                    </button>
                    {(isAdmin || delegation.delegator_id === user.id) && (
                        <>
                            <button onClick={() => onEdit(delegation)} className="text-text-muted hover:text-blue-500 transition-colors p-1" title="Edit">
                                <span className="material-symbols-outlined text-xl">edit</span>
                            </button>
                            <button onClick={() => onDelete(delegation.id)} className="text-text-muted hover:text-red-500 transition-colors p-1" title="Delete">
                                <span className="material-symbols-outlined text-xl">delete</span>
                            </button>
                        </>
                    )}
                </div>
            </div>

            {/* Info Blocks - Grid of 2 */}
            <div className="grid grid-cols-2 gap-2 sm:gap-3 px-4 pb-4">
                {/* Assignee */}
                <div className="bg-blue-500/5 rounded-lg p-2 sm:p-3 flex items-center gap-2 sm:gap-3 border border-blue-500/10 group-hover:border-blue-500/20 transition-colors">
                    <div className="size-7 sm:size-8 rounded bg-blue-500/10 flex items-center justify-center text-blue-500 shrink-0">
                        <span className="material-symbols-outlined text-sm sm:text-base">person</span>
                    </div>
                    <div className="min-w-0">
                        <p className="text-[9px] sm:text-[10px] font-bold text-blue-500/80 uppercase tracking-wide truncate">Assignee</p>
                        <p className="text-text-main font-bold text-xs sm:text-sm truncate">{delegation.delegator_name || 'N/A'}</p>
                    </div>
                </div>

                {/* Doer */}
                <div className="bg-purple-500/5 rounded-lg p-2 sm:p-3 flex items-center gap-2 sm:gap-3 border border-purple-500/10 group-hover:border-purple-500/20 transition-colors">
                    <div className="size-7 sm:size-8 rounded bg-purple-500/10 flex items-center justify-center text-purple-500 shrink-0">
                        <span className="material-symbols-outlined text-sm sm:text-base">group</span>
                    </div>
                    <div className="min-w-0">
                        <p className="text-[9px] sm:text-[10px] font-bold text-purple-500/80 uppercase tracking-wide truncate">Doer</p>
                        <p className="text-text-main font-bold text-xs sm:text-sm truncate">{delegation.doer_name || 'N/A'}</p>
                    </div>
                </div>

                {/* Department */}
                <div className="bg-emerald-500/5 rounded-lg p-2 sm:p-3 flex items-center gap-2 sm:gap-3 border border-emerald-500/10 group-hover:border-emerald-500/20 transition-colors">
                    <div className="size-7 sm:size-8 rounded bg-emerald-500/10 flex items-center justify-center text-emerald-500 shrink-0">
                        <span className="material-symbols-outlined text-sm sm:text-base">domain</span>
                    </div>
                    <div className="min-w-0">
                        <p className="text-[9px] sm:text-[10px] font-bold text-emerald-500/80 uppercase tracking-wide truncate">Department</p>
                        <p className="text-text-main font-bold text-xs sm:text-sm truncate">{delegation.department || 'N/A'}</p>
                    </div>
                </div>

                {/* Priority */}
                <div className="bg-red-500/5 rounded-lg p-2 sm:p-3 flex items-center gap-2 sm:gap-3 border border-red-500/10 group-hover:border-red-500/20 transition-colors">
                    <div className="size-7 sm:size-8 rounded bg-red-500/10 flex items-center justify-center text-red-500 shrink-0">
                        <span className="material-symbols-outlined text-sm sm:text-base">warning</span>
                    </div>
                    <div className="min-w-0">
                        <p className="text-[9px] sm:text-[10px] font-bold text-red-500/80 uppercase tracking-wide truncate">Priority</p>
                        <p className="text-text-main font-bold text-xs sm:text-sm capitalize truncate">{delegation.priority || 'N/A'}</p>
                    </div>
                </div>
            </div>

            {/* Footer Status Bar */}
            <div className="bg-bg-main/50 px-4 py-3 flex flex-wrap gap-y-3 gap-x-4 justify-between items-center border-t border-border-main text-text-muted">
                {/* Due Date */}
                <div className="flex items-center gap-2 shrink-0">
                    <div className="bg-bg-main p-1 rounded border border-border-main shrink-0">
                        <span className="material-symbols-outlined text-[14px]">event</span>
                    </div>
                    <div>
                        <p className="text-[9px] font-bold uppercase opacity-70 tracking-wider">Due Date</p>
                        <p className="text-text-main text-[11px] font-semibold">{formatDate(delegation.due_date)}</p>
                    </div>
                </div>

                {/* Evidence */}
                <div className="flex items-center gap-2 shrink-0">
                    <div className={`p-1 rounded border shrink-0 ${delegation.evidence_required ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20' : 'bg-bg-main text-text-muted border-border-main'}`}>
                        <span className="material-symbols-outlined text-[14px]">{delegation.evidence_required ? 'check_circle' : 'cancel'}</span>
                    </div>
                    <div>
                        <p className="text-[9px] font-bold uppercase opacity-70 tracking-wider">Evidence</p>
                        <p className={`text-[11px] font-semibold ${delegation.evidence_required ? 'text-emerald-500' : 'text-text-muted'}`}>
                            {delegation.evidence_required ? 'Required' : 'Optional'}
                        </p>
                    </div>
                </div>

                {/* Created */}
                <div className="flex items-center gap-2 shrink-0">
                    <div className="bg-bg-main p-1 rounded border border-border-main shrink-0">
                        <span className="material-symbols-outlined text-[14px]">schedule</span>
                    </div>
                    <div>
                        <p className="text-[9px] font-bold uppercase opacity-70 tracking-wider">Created</p>
                        <p className="text-text-main text-[11px] font-semibold">{new Date(delegation.created_at).toLocaleDateString()}</p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default DelegationCard;
