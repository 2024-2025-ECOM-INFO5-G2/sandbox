import './header.scss';
import React from 'react';
import { BrandLogo, NavUser } from './header-components';

export interface IHeaderProps {
  isAuthenticated: boolean;
}

const Header = (props: IHeaderProps) => {
  return (
    <div id="app-header">
      <div className="MMM-Header">
        <BrandLogo />
        <NavUser isAuthenticated={props.isAuthenticated} />
      </div>
    </div>
  );
};

export default Header;
