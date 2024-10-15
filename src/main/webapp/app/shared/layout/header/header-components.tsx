import React from 'react';
import { Translate } from 'react-jhipster';

import { NavItem, NavLink, NavbarBrand } from 'reactstrap';
import { NavLink as Link } from 'react-router-dom';

export const BrandLogo = () => (
  <NavbarBrand tag={Link} to="/" className="brand-logo">
    <span>
      <img src="content/images/logo.png" width={300} />
    </span>
  </NavbarBrand>
);

export const NavUser = ({ isAuthenticated }) => (
  <div>
    <ul>
      {!isAuthenticated && (
        <NavItem>
          <NavLink tag={Link} to="/account/register">
            <span>
              <Translate contentKey="header.inscrire"></Translate>
            </span>
          </NavLink>
        </NavItem>
      )}

      <NavItem>
        <NavLink tag={Link} to="https://www.leetchi.com/c/mes-meilleurs-menus">
          <span>
            <Translate contentKey="header.don"></Translate>
          </span>
        </NavLink>
      </NavItem>

      {isAuthenticated && (
        <NavItem>
          <NavLink tag={Link} to="/account/settings">
            <span>
              <Translate contentKey="header.compte"></Translate>
            </span>
          </NavLink>
        </NavItem>
      )}
    </ul>
  </div>
);
