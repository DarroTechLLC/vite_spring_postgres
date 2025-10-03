import { BarChart, FileText, Home, Settings } from 'lucide-react';
import { NavLink } from 'react-router-dom';

const navItems = [
  { to: '/dashboard', icon: Home, label: 'Dashboard' },
  { to: '/dashboard/view1', icon: FileText, label: 'View 1' },
  { to: '/dashboard/view2', icon: BarChart, label: 'View 2' },
  { to: '/dashboard/view3', icon: Settings, label: 'View 3' },
];

export const Sidebar = () => {
  return (
    <div className="w-64 bg-white shadow-lg">
      <div className="p-6">
        <h1 className="text-2xl font-bold text-gray-800">My App</h1>
      </div>
      <nav className="mt-6">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100 transition-colors ${
                isActive ? 'bg-gray-100 border-r-4 border-primary' : ''
              }`
            }
          >
            <item.icon className="w-5 h-5 mr-3" />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
    </div>
  );
};
